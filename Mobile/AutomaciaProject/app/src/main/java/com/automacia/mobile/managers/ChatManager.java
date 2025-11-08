package com.automacia.mobile.managers;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.automacia.mobile.models.MensagemDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.DatabaseHelper;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

public class ChatManager {

    private static final String TAG = "ChatManager";
    private static final String SERVER_URL = "http://192.168.1.13:6969";
    private static final int CONNECTION_TIMEOUT = 10000;
    private static final int DATABASE_TIMEOUT = 10000;

    // Enums para padronização
    public enum ChatEvents {
        NOVA_MENSAGEM("nova_mensagem"),
        DIGITANDO("digitando"),
        ENTRAR_SALA("entrar_sala"),
        ENVIAR_MENSAGEM("enviar_mensagem"),
        SAIR_SALA("sair_sala"),
        TROCAR_FUNCIONARIO("trocar_funcionario"),
        MENSAGEM_CONFIRMADA("mensagem_confirmada");

        private final String value;

        ChatEvents(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    public enum ErrorType {
        SOCKET("SOCKET_ERROR"),
        BANCO("DATABASE_ERROR"),
        TIMEOUT("TIMEOUT_ERROR"),
        DESCONHECIDO("UNKNOWN_ERROR"),
        VALIDACAO("VALIDATION_ERROR");

        private final String value;

        ErrorType(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    public enum TipoUsuario {
        PACIENTE("paciente"),
        FUNCIONARIO("funcionario");

        private final String value;

        TipoUsuario(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    // Variáveis de instância
    private Socket mSocket;
    private Context context;
    private UsuarioDTO usuarioLogado;
    private int funcionarioIdAtual; // MUDANÇA: Agora é dinâmico
    private Handler mainHandler;
    private ExecutorService databaseExecutor;
    private volatile boolean isConnected = false;
    private volatile boolean isTrocandoFuncionario = false; // Flag para controle de troca

    // Interfaces para callbacks
    public interface OnMensagemRecebidaListener {
        void onMensagemRecebida(MensagemDTO mensagem);
    }

    public interface OnStatusConexaoListener {
        void onStatusChanged(boolean conectado);
    }

    public interface OnDigitandoListener {
        void onDigitando(boolean digitando, String usuario);
    }

    public interface OnMensagensCarregadasListener {
        void onMensagensCarregadas(List<MensagemDTO> mensagens);
        void onErro(ErrorType tipo, String erro);
    }

    public interface OnMensagemEnviadaListener {
        void onSucesso(MensagemDTO mensagem);
        void onErro(ErrorType tipo, String erro);
    }

    public interface OnSalaListener {
        void onEntrou(String salaId);
        void onErro(ErrorType tipo, String erro);
    }

    // NOVO: Interface para troca de funcionário
    public interface OnTrocaFuncionarioListener {
        void onTrocaSucesso(int funcionarioIdAntigo, int funcionarioIdNovo);
        void onTrocaErro(ErrorType tipo, String mensagem);
    }

    // Listeners
    private OnMensagemRecebidaListener onMensagemRecebidaListener;
    private OnStatusConexaoListener onStatusConexaoListener;
    private OnDigitandoListener onDigitandoListener;

    // MUDANÇA: Construtor agora recebe funcionarioId inicial
    public ChatManager(Context context, UsuarioDTO usuario, int funcionarioId) {
        this.context = context;
        this.usuarioLogado = usuario;
        this.funcionarioIdAtual = funcionarioId;
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.databaseExecutor = Executors.newSingleThreadExecutor();
        inicializarSocket();
    }

    private void inicializarSocket() {
        try {
            IO.Options options = new IO.Options();
            options.forceNew = true;
            options.reconnection = true;
            options.reconnectionAttempts = 5;
            options.reconnectionDelay = 1000;
            options.timeout = CONNECTION_TIMEOUT;
            options.transports = new String[]{"websocket", "polling"};
            options.upgrade = true;
            options.rememberUpgrade = true;

            mSocket = IO.socket(SERVER_URL, options);
            configurarEventListeners();

            mSocket.connect();

        } catch (URISyntaxException e) {
            Log.e(TAG, "Erro ao inicializar Socket.IO", e);
            notificarErro(ErrorType.SOCKET, "Erro ao inicializar conexão: " + e.getMessage());
        }
    }

    private void configurarEventListeners() {
        mSocket.on(Socket.EVENT_CONNECT, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                Log.d(TAG, "Conectado ao servidor Socket.IO");
                isConnected = true;
                mainHandler.post(() -> {
                    if (onStatusConexaoListener != null) {
                        onStatusConexaoListener.onStatusChanged(true);
                    }
                });

                // Só entra na sala se não estiver trocando funcionário
                if (!isTrocandoFuncionario) {
                    entrarNaSala();
                }
            }
        });

        mSocket.on(Socket.EVENT_DISCONNECT, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                Log.d(TAG, "Desconectado do servidor Socket.IO");
                isConnected = false;
                mainHandler.post(() -> {
                    if (onStatusConexaoListener != null) {
                        onStatusConexaoListener.onStatusChanged(false);
                    }
                });
            }
        });

        mSocket.on(Socket.EVENT_CONNECT_ERROR, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                String erro = args.length > 0 ? args[0].toString() : "Erro desconhecido";
                Log.e(TAG, "Erro de conexão: " + erro);
                isConnected = false;
                mainHandler.post(() -> {
                    if (onStatusConexaoListener != null) {
                        onStatusConexaoListener.onStatusChanged(false);
                    }
                });
            }
        });

        // Escutar mensagens recebidas
        mSocket.on(ChatEvents.NOVA_MENSAGEM.getValue(), new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                processarNovaMensagem(args);
            }
        });

        // Escutar indicador de digitação
        mSocket.on(ChatEvents.DIGITANDO.getValue(), new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                processarIndicadorDigitacao(args);
            }
        });

        // Escutar confirmação de entrada na sala
        mSocket.on("sala_confirmada", new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                try {
                    JSONObject data = (JSONObject) args[0];
                    String salaId = data.getString("sala");
                    int funcionarioId = data.getInt("funcionarioId");

                    Log.d(TAG, "Confirmação de entrada na sala: " + salaId +
                            " (Funcionário ID: " + funcionarioId + ")");

                } catch (JSONException e) {
                    Log.e(TAG, "Erro ao processar confirmação de sala", e);
                }
            }
        });

        // NOVO: Escutar confirmação de troca de funcionário
        mSocket.on("funcionario_trocado", new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                processarTrocaFuncionario(args);
            }
        });

        // Escutar erros do servidor
        mSocket.on("error", new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                try {
                    JSONObject data = (JSONObject) args[0];
                    String errorType = data.getString("error_type");
                    String message = data.getString("message");

                    ErrorType tipo = parseErrorType(errorType);
                    Log.e(TAG, "Erro do servidor (" + errorType + "): " + message);
                    notificarErro(tipo, message);
                } catch (JSONException e) {
                    Log.e(TAG, "Erro ao processar erro do servidor", e);
                    notificarErro(ErrorType.SOCKET, "Erro de comunicação com servidor");
                }
            }
        });
    }

    // NOVO: Processar confirmação de troca de funcionário
    private void processarTrocaFuncionario(Object... args) {
        try {
            JSONObject data = (JSONObject) args[0];

            String salaId = data.getString("sala");
            int funcionarioIdAntigo = data.getInt("funcionarioIdAntigo");
            int funcionarioIdNovo = data.getInt("funcionarioIdNovo");

            Log.d(TAG, "=== TROCA DE FUNCIONÁRIO CONFIRMADA ===");
            Log.d(TAG, "Sala nova: " + salaId);
            Log.d(TAG, "Funcionário antigo: " + funcionarioIdAntigo);
            Log.d(TAG, "Funcionário novo: " + funcionarioIdNovo);
            Log.d(TAG, "======================================");

            // Atualizar ID local
            funcionarioIdAtual = funcionarioIdNovo;
            isTrocandoFuncionario = false;

            // Notificar sucesso na thread principal
            mainHandler.post(() -> {
                // Aqui o Fragment vai receber a notificação e pode recarregar mensagens
                Log.i(TAG, "Troca concluída com sucesso! Funcionário atual: " + funcionarioIdAtual);
            });

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao processar confirmação de troca", e);
            isTrocandoFuncionario = false;
        }
    }

    private ErrorType parseErrorType(String errorType) {
        switch (errorType) {
            case "DATABASE_ERROR":
                return ErrorType.BANCO;
            case "SOCKET_ERROR":
                return ErrorType.SOCKET;
            case "VALIDATION_ERROR":
                return ErrorType.VALIDACAO;
            case "TIMEOUT_ERROR":
                return ErrorType.TIMEOUT;
            default:
                return ErrorType.DESCONHECIDO;
        }
    }

    private void processarNovaMensagem(Object... args) {
        try {
            JSONObject data = (JSONObject) args[0];

            // Log completo para debug
            Log.d(TAG, "=== NOVA MENSAGEM RECEBIDA ===");
            Log.d(TAG, "JSON completo: " + data.toString());

            // MUDANÇA: Verificar se a mensagem é para o funcionário atual
            int funcionarioIdMensagem = data.getInt("funcionarioId");
            if (funcionarioIdMensagem != funcionarioIdAtual) {
                Log.d(TAG, "Mensagem ignorada - Funcionário diferente: " +
                        funcionarioIdMensagem + " (atual: " + funcionarioIdAtual + ")");
                return;
            }

            MensagemDTO mensagem = new MensagemDTO();

            // Campos obrigatórios
            mensagem.setMensagem(data.getString("mensagem"));
            mensagem.setPacienteCpf(data.getString("cpfPaciente"));
            mensagem.setFuncionarioId(funcionarioIdMensagem);

            // Determinar se é paciente
            boolean ehPaciente = data.optBoolean("msgPaciente", false);
            if (!ehPaciente && data.has("tipo_remetente")) {
                ehPaciente = "paciente".equals(data.getString("tipo_remetente"));
            }
            mensagem.setEhPaciente(ehPaciente);

            // ID do chat se disponível
            if (data.has("id_chat")) {
                mensagem.setIdChat(data.getInt("id_chat"));
            }

            // Timestamp
            Date horaEnvio = null;
            if (data.has("timestamp")) {
                try {
                    String timestamp = data.getString("timestamp");
                    SimpleDateFormat sdf = new SimpleDateFormat(
                            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", Locale.getDefault());
                    horaEnvio = sdf.parse(timestamp);
                } catch (ParseException e) {
                    Log.w(TAG, "Erro ao parsear timestamp formato completo", e);
                    try {
                        String timestamp = data.getString("timestamp");
                        SimpleDateFormat sdf = new SimpleDateFormat(
                                "yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
                        horaEnvio = sdf.parse(timestamp);
                    } catch (ParseException e2) {
                        Log.w(TAG, "Erro ao parsear timestamp formato ISO", e2);
                    }
                }
            }

            if (horaEnvio == null) {
                horaEnvio = new Date();
            }
            mensagem.setHoraEnvio(horaEnvio);

            // Log detalhado
            Log.d(TAG, "Mensagem processada:");
            Log.d(TAG, "  - Texto: " + mensagem.getMensagem());
            Log.d(TAG, "  - CPF Paciente: " + mensagem.getPacienteCpf());
            Log.d(TAG, "  - Funcionario ID: " + mensagem.getFuncionarioId());
            Log.d(TAG, "  - eh Paciente: " + ehPaciente);
            Log.d(TAG, "=================================");

            // Notificar UI na thread principal
            final MensagemDTO mensagemFinal = mensagem;
            mainHandler.post(() -> {
                if (onMensagemRecebidaListener != null) {
                    onMensagemRecebidaListener.onMensagemRecebida(mensagemFinal);
                }
            });

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao processar mensagem recebida", e);
            Log.e(TAG, "JSON que causou erro: " + args[0].toString());
        }
    }

    private void processarIndicadorDigitacao(Object... args) {
        try {
            JSONObject data = (JSONObject) args[0];
            boolean digitando = data.getBoolean("digitando");
            String usuario = data.getString("usuario");

            // Só mostrar se não for o próprio usuário digitando
            if (!usuario.equals(usuarioLogado.getCpf())) {
                mainHandler.post(() -> {
                    if (onDigitandoListener != null) {
                        onDigitandoListener.onDigitando(digitando, usuario);
                    }
                });
            }
        } catch (JSONException e) {
            Log.e(TAG, "Erro ao processar indicador de digitação", e);
        }
    }

    private void entrarNaSala() {
        try {
            JSONObject data = new JSONObject();
            data.put("cpfPaciente", usuarioLogado.getCpf());
            data.put("funcionarioId", funcionarioIdAtual); // MUDANÇA: Usa ID dinâmico
            data.put("tipoUsuario", TipoUsuario.PACIENTE.getValue());

            mSocket.emit(ChatEvents.ENTRAR_SALA.getValue(), data);
            Log.d(TAG, "Solicitando entrada na sala - CPF: " + usuarioLogado.getCpf() +
                    ", Funcionário: " + funcionarioIdAtual);

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao entrar na sala", e);
            notificarErro(ErrorType.SOCKET, "Erro ao entrar na sala de chat");
        }
    }

    // NOVO: Metodo para trocar de funcionário
    public void trocarFuncionario(int novoFuncionarioId, OnTrocaFuncionarioListener listener) {
        if (!isConnected) {
            if (listener != null) {
                mainHandler.post(() -> listener.onTrocaErro(
                        ErrorType.SOCKET,
                        "Não conectado ao servidor"
                ));
            }
            return;
        }

        if (novoFuncionarioId == funcionarioIdAtual) {
            Log.w(TAG, "Tentativa de trocar para o mesmo funcionário: " + novoFuncionarioId);
            if (listener != null) {
                mainHandler.post(() -> listener.onTrocaErro(
                        ErrorType.VALIDACAO,
                        "Você já está conversando com este funcionário"
                ));
            }
            return;
        }

        isTrocandoFuncionario = true;
        final int funcionarioIdAntigoTemp = funcionarioIdAtual;

        try {
            JSONObject data = new JSONObject();
            data.put("cpfPaciente", usuarioLogado.getCpf());
            data.put("funcionarioIdAntigo", funcionarioIdAtual);
            data.put("funcionarioIdNovo", novoFuncionarioId);

            mSocket.emit(ChatEvents.TROCAR_FUNCIONARIO.getValue(), data);

            Log.d(TAG, "Solicitando troca de funcionário:");
            Log.d(TAG, "  - Funcionário antigo: " + funcionarioIdAtual);
            Log.d(TAG, "  - Funcionário novo: " + novoFuncionarioId);

            // Aguardar confirmação do servidor (timeout de 5 segundos)
            mainHandler.postDelayed(() -> {
                if (isTrocandoFuncionario) {
                    Log.e(TAG, "Timeout ao aguardar confirmação de troca");
                    isTrocandoFuncionario = false;

                    if (listener != null) {
                        listener.onTrocaErro(
                                ErrorType.TIMEOUT,
                                "Tempo esgotado ao trocar funcionário"
                        );
                    }
                }
            }, 5000);

            // Listener temporário para capturar confirmação
            mSocket.once("funcionario_trocado", new Emitter.Listener() {
                @Override
                public void call(Object... args) {
                    try {
                        JSONObject data = (JSONObject) args[0];
                        int funcionarioIdNovo = data.getInt("funcionarioIdNovo");

                        funcionarioIdAtual = funcionarioIdNovo;
                        isTrocandoFuncionario = false;

                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onTrocaSucesso(funcionarioIdAntigoTemp, funcionarioIdNovo);
                            }
                        });

                    } catch (JSONException e) {
                        Log.e(TAG, "Erro ao processar confirmação de troca", e);
                        isTrocandoFuncionario = false;

                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onTrocaErro(
                                        ErrorType.SOCKET,
                                        "Erro ao processar resposta do servidor"
                                );
                            }
                        });
                    }
                }
            });

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao trocar funcionário", e);
            isTrocandoFuncionario = false;

            if (listener != null) {
                mainHandler.post(() -> listener.onTrocaErro(
                        ErrorType.SOCKET,
                        "Erro ao trocar funcionário: " + e.getMessage()
                ));
            }
        }
    }

    public void conectar() {
        if (mSocket != null && !mSocket.connected()) {
            mSocket.connect();
        }
    }

    public void desconectar() {
        if (mSocket != null) {
            mSocket.disconnect();
            isConnected = false;
        }
    }

    public void enviarMensagem(String mensagem, OnMensagemEnviadaListener listener) {
        if (mensagem == null || mensagem.trim().isEmpty()) {
            if (listener != null) {
                mainHandler.post(() -> listener.onErro(ErrorType.VALIDACAO, "Mensagem não pode estar vazia"));
            }
            return;
        }

        if (!isConnected) {
            if (listener != null) {
                mainHandler.post(() -> listener.onErro(ErrorType.SOCKET, "Não conectado ao servidor"));
            }
            return;
        }

        try {
            JSONObject data = new JSONObject();
            data.put("mensagem", mensagem.trim());
            data.put("cpfPaciente", usuarioLogado.getCpf());
            data.put("funcionarioId", funcionarioIdAtual); // MUDANÇA: Usa ID dinâmico
            data.put("tipoRemetente", TipoUsuario.PACIENTE.getValue());
            data.put("msgPaciente", true);

            mSocket.emit(ChatEvents.ENVIAR_MENSAGEM.getValue(), data);

            // Criar mensagem local temporária
            MensagemDTO mensagemTemp = new MensagemDTO(mensagem.trim(), true);
            mensagemTemp.setPacienteCpf(usuarioLogado.getCpf());
            mensagemTemp.setFuncionarioId(funcionarioIdAtual);
            mensagemTemp.setHoraEnvio(new Date());

            mainHandler.post(() -> {
                if (listener != null) {
                    listener.onSucesso(mensagemTemp);
                }
            });

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao enviar mensagem", e);
            mainHandler.post(() -> {
                if (listener != null) {
                    listener.onErro(ErrorType.SOCKET, "Erro ao enviar mensagem");
                }
            });
        }
    }

    public void carregarMensagens(OnMensagensCarregadasListener listener) {
        databaseExecutor.execute(() -> {
            Connection connection = null;
            CallableStatement stmt = null;
            ResultSet rs = null;

            try {
                connection = DatabaseHelper.getConnection();
                stmt = connection.prepareCall("{call Mostra_Chat(?, ?)}");

                stmt.setString(1, usuarioLogado.getCpf());
                stmt.setInt(2, funcionarioIdAtual); // MUDANÇA: Usa ID dinâmico
                stmt.setQueryTimeout(DATABASE_TIMEOUT / 1000);

                rs = stmt.executeQuery();
                List<MensagemDTO> mensagens = new ArrayList<>();

                if (!rs.isBeforeFirst()) {
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onMensagensCarregadas(new ArrayList<>());
                        }
                    });
                    return;
                }

                while (rs.next()) {
                    String primeiraColuna = rs.getString(1);
                    if (isErrorMessage(primeiraColuna)) {
                        final String erro = primeiraColuna;
                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onErro(ErrorType.BANCO, erro);
                            }
                        });
                        return;
                    }

                    try {
                        MensagemDTO mensagem = new MensagemDTO();
                        mensagem.setIdChat(rs.getInt("ID_Chat"));
                        mensagem.setPacienteCpf(rs.getString("Paciente_F"));
                        mensagem.setFuncionarioId(rs.getInt("Funcionar_Rec"));
                        mensagem.setMensagem(rs.getString("Mensagem"));
                        mensagem.setHoraEnvio(rs.getTimestamp("Hora_Envio"));
                        mensagem.setEhPaciente(rs.getBoolean("MsgPaciente"));

                        mensagens.add(mensagem);
                    } catch (SQLException e) {
                        Log.w(TAG, "Erro ao processar linha da mensagem", e);
                    }
                }

                final List<MensagemDTO> mensagensFinais = mensagens;
                mainHandler.post(() -> {
                    if (listener != null) {
                        listener.onMensagensCarregadas(mensagensFinais);
                    }
                });

            } catch (SQLException e) {
                Log.e(TAG, "Erro ao carregar mensagens do banco", e);
                mainHandler.post(() -> {
                    if (listener != null) {
                        listener.onErro(ErrorType.BANCO, "Erro ao carregar mensagens: " + e.getMessage());
                    }
                });
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (connection != null) connection.close();
                } catch (SQLException e) {
                    Log.e(TAG, "Erro ao fechar recursos do banco", e);
                }
            }
        });
    }

    private boolean isErrorMessage(String mensagem) {
        return mensagem != null && (
                mensagem.contains("não encontrado") ||
                        mensagem.contains("inativo") ||
                        mensagem.contains("Inválido") ||
                        mensagem.equals("CPF Inválido") ||
                        mensagem.equals("Funcionário Inválido") ||
                        mensagem.equals("Informações Inválidas") ||
                        mensagem.startsWith("Erro ao")
        );
    }

    public void indicarDigitando(boolean digitando) {
        if (!isConnected) return;

        try {
            JSONObject data = new JSONObject();
            data.put("digitando", digitando);
            data.put("usuario", usuarioLogado.getCpf());
            data.put("cpfPaciente", usuarioLogado.getCpf());
            data.put("funcionarioId", funcionarioIdAtual); // MUDANÇA: Usa ID dinâmico

            mSocket.emit(ChatEvents.DIGITANDO.getValue(), data);

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao indicar digitação", e);
        }
    }

    public boolean isConectado() {
        return mSocket != null && mSocket.connected() && isConnected;
    }

    // NOVO: Getter para o funcionário atual
    public int getFuncionarioIdAtual() {
        return funcionarioIdAtual;
    }

    // NOVO: Setter para quando vier da Intent (antes de conectar)
    public void setFuncionarioId(int funcionarioId) {
        if (!isConnected) {
            this.funcionarioIdAtual = funcionarioId;
            Log.d(TAG, "Funcionário ID definido para: " + funcionarioId);
        } else {
            Log.w(TAG, "Não é possível alterar funcionário diretamente quando conectado. Use trocarFuncionario()");
        }
    }

    private void notificarErro(ErrorType tipo, String mensagem) {
        Log.e(TAG, tipo.getValue() + ": " + mensagem);
    }

    // Setters para listeners
    public void setOnMensagemRecebidaListener(OnMensagemRecebidaListener listener) {
        this.onMensagemRecebidaListener = listener;
    }

    public void setOnStatusConexaoListener(OnStatusConexaoListener listener) {
        this.onStatusConexaoListener = listener;
    }

    public void setOnDigitandoListener(OnDigitandoListener listener) {
        this.onDigitandoListener = listener;
    }

    public void limparListeners() {
        this.onMensagemRecebidaListener = null;
        this.onStatusConexaoListener = null;
        this.onDigitandoListener = null;
    }

    public void destroy() {
        limparListeners();
        desconectar();

        if (databaseExecutor != null && !databaseExecutor.isShutdown()) {
            databaseExecutor.shutdown();
            try {
                if (!databaseExecutor.awaitTermination(5, TimeUnit.SECONDS)) {
                    databaseExecutor.shutdownNow();
                }
            } catch (InterruptedException e) {
                databaseExecutor.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
    }
}
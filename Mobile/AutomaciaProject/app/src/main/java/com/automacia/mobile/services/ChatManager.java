package com.automacia.mobile.services;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.automacia.mobile.models.MensagemDTO;
import com.automacia.mobile.models.UsuarioDTO;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

public class ChatManager {

    private static final String TAG = "ChatManager";
    private static final String SERVER_URL = "http://192.168.20.61:6969";
    private static final int FUNCIONARIO_ID = 1; // ID fixo do funcionário para este exemplo

    private Socket mSocket;
    private Context context;
    private UsuarioDTO usuarioLogado;
    private Handler mainHandler;

    // Interfaces para callbacks
    public interface OnMensagemRecebidaListener {
        void onMensagemRecebida(MensagemDTO mensagem);
    }

    public interface OnStatusConexaoListener {
        void onStatusChanged(boolean conectado);
    }

    public interface OnDigitandoListener {
        void onDigitando(boolean digitando);
    }

    public interface OnMensagensCarregadasListener {
        void onMensagensCarregadas(List<MensagemDTO> mensagens);
        void onErro(String erro);
    }

    public interface OnMensagemEnviadaListener {
        void onSucesso(String mensagem);
        void onErro(String erro);
    }

    private OnMensagemRecebidaListener onMensagemRecebidaListener;
    private OnStatusConexaoListener onStatusConexaoListener;
    private OnDigitandoListener onDigitandoListener;

    public ChatManager(Context context, UsuarioDTO usuario) {
        this.context = context;
        this.usuarioLogado = usuario;
        this.mainHandler = new Handler(Looper.getMainLooper());
        inicializarSocket();
    }

    private void inicializarSocket() {
        try {
            IO.Options options = new IO.Options();
            options.forceNew = true;
            options.reconnection = true;
            options.reconnectionAttempts = 5;
            options.reconnectionDelay = 1000;

            mSocket = IO.socket(SERVER_URL, options);

            mSocket.on(Socket.EVENT_CONNECT, new Emitter.Listener() {
                @Override
                public void call(Object... args) {
                    Log.d(TAG, "Conectado ao servidor Socket.IO");
                    mainHandler.post(() -> {
                        if (onStatusConexaoListener != null) {
                            onStatusConexaoListener.onStatusChanged(true);
                        }
                    });

                    // Entrar na sala do chat específico
                    entrarNaSala();
                }
            });

            mSocket.on(Socket.EVENT_DISCONNECT, new Emitter.Listener() {
                @Override
                public void call(Object... args) {
                    Log.d(TAG, "Desconectado do servidor Socket.IO");
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
                    Log.e(TAG, "Erro de conexão: " + args[0].toString());
                    mainHandler.post(() -> {
                        if (onStatusConexaoListener != null) {
                            onStatusConexaoListener.onStatusChanged(false);
                        }
                    });
                }
            });

            // Escutar mensagens recebidas
            mSocket.on("nova_mensagem", new Emitter.Listener() {
                @Override
                public void call(Object... args) {
                    try {
                        JSONObject data = (JSONObject) args[0];
                        String mensagemTexto = data.getString("mensagem");
                        String remetente = data.getString("remetente");
                        String timestamp = data.getString("timestamp");

                        // Criar objeto mensagem
                        MensagemDTO mensagem = new MensagemDTO();
                        mensagem.setMensagem(mensagemTexto);
                        mensagem.setEhPaciente(false); // Mensagem do funcionário

                        // Parse do timestamp
                        try {
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
                            mensagem.setHoraEnvio(sdf.parse(timestamp));
                        } catch (Exception e) {
                            mensagem.setHoraEnvio(new Date());
                        }

                        mainHandler.post(() -> {
                            if (onMensagemRecebidaListener != null) {
                                onMensagemRecebidaListener.onMensagemRecebida(mensagem);
                            }
                        });

                    } catch (JSONException e) {
                        Log.e(TAG, "Erro ao processar mensagem recebida", e);
                    }
                }
            });

            // Escutar indicador de digitação
            mSocket.on("digitando", new Emitter.Listener() {
                @Override
                public void call(Object... args) {
                    try {
                        JSONObject data = (JSONObject) args[0];
                        boolean digitando = data.getBoolean("digitando");
                        String usuario = data.getString("usuario");

                        // Só mostrar se não for o próprio usuário digitando
                        if (!usuario.equals(usuarioLogado.getCpf())) {
                            mainHandler.post(() -> {
                                if (onDigitandoListener != null) {
                                    onDigitandoListener.onDigitando(digitando);
                                }
                            });
                        }
                    } catch (JSONException e) {
                        Log.e(TAG, "Erro ao processar indicador de digitação", e);
                    }
                }
            });

        } catch (URISyntaxException e) {
            Log.e(TAG, "Erro ao inicializar Socket.IO", e);
        }
    }

    private void entrarNaSala() {
        try {
            JSONObject data = new JSONObject();
            data.put("cpfPaciente", usuarioLogado.getCpf());
            data.put("funcionarioId", FUNCIONARIO_ID);
            data.put("tipoUsuario", "paciente");

            mSocket.emit("entrar_sala", data);
            Log.d(TAG, "Entrando na sala do chat: " + usuarioLogado.getCpf());

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao entrar na sala", e);
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
        }
    }

    public void enviarMensagem(String mensagem, OnMensagemEnviadaListener listener) {
        // Primeiro salvar no banco via procedure
        new Thread(() -> {
            try {
                Connection connection = DatabaseHelper.getConnection();
                CallableStatement stmt = connection.prepareCall("{call Envia_Mensagem_P(?, ?, ?)}");

                stmt.setInt(1, FUNCIONARIO_ID);
                stmt.setString(2, usuarioLogado.getCpf());
                stmt.setString(3, mensagem);

                ResultSet rs = stmt.executeQuery();

                String resultado = "";
                if (rs.next()) {
                    resultado = rs.getString("Mensagem_Retorno_P");
                }

                rs.close();
                stmt.close();
                connection.close();

                final String resultadoFinal = resultado;

                if (resultado.equals("Mensagem enviada com sucesso")) {
                    // Enviar via Socket.IO
                    try {
                        JSONObject data = new JSONObject();
                        data.put("mensagem", mensagem);
                        data.put("cpfPaciente", usuarioLogado.getCpf());
                        data.put("funcionarioId", FUNCIONARIO_ID);
                        data.put("remetente", usuarioLogado.getCpf());
                        data.put("tipoRemetente", "paciente");

                        mSocket.emit("enviar_mensagem", data);

                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onSucesso(resultadoFinal);
                            }
                        });

                    } catch (JSONException e) {
                        Log.e(TAG, "Erro ao enviar mensagem via Socket.IO", e);
                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onErro("Erro ao enviar mensagem");
                            }
                        });
                    }
                } else {
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onErro(resultadoFinal);
                        }
                    });
                }

            } catch (SQLException e) {
                Log.e(TAG, "Erro no banco de dados ao enviar mensagem", e);
                mainHandler.post(() -> {
                    if (listener != null) {
                        listener.onErro("Erro no banco de dados");
                    }
                });
            }
        }).start();
    }

    public void carregarMensagens(OnMensagensCarregadasListener listener) {
        new Thread(() -> {
            try {
                Connection connection = DatabaseHelper.getConnection();
                CallableStatement stmt = connection.prepareCall("{call Mostra_Chat(?, ?)}");

                stmt.setString(1, usuarioLogado.getCpf());
                stmt.setInt(2, FUNCIONARIO_ID);

                ResultSet rs = stmt.executeQuery();

                List<MensagemDTO> mensagens = new ArrayList<>();

                // Verificar se há erro
                if (rs.next()) {
                    String primeiroResultado = rs.getString(1);

                    // Se for uma mensagem de erro
                    if (primeiroResultado.equals("CPF Inválido") ||
                            primeiroResultado.equals("Funcionário Inválido") ||
                            primeiroResultado.equals("Informações Inválidas")) {

                        rs.close();
                        stmt.close();
                        connection.close();

                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onErro(primeiroResultado);
                            }
                        });
                        return;
                    }

                    // Se não é erro, processar as mensagens
                    // Note: Como o resultado já foi lido, precisamos incluí-lo
                    if (primeiroResultado != null && !primeiroResultado.trim().isEmpty()) {
                        MensagemDTO mensagem = new MensagemDTO();
                        mensagem.setMensagem(primeiroResultado);
                        // Aqui você precisa determinar se é do paciente ou funcionário
                        // Por enquanto, vou assumir uma lógica baseada no conteúdo ou posição
                        mensagem.setEhPaciente(true); // Placeholder - implementar lógica real
                        mensagem.setHoraEnvio(new Date()); // Placeholder - pegar do banco
                        mensagens.add(mensagem);
                    }

                    // Continuar lendo o restante
                    while (rs.next()) {
                        String mensagemTexto = rs.getString("Mensagem");
                        if (mensagemTexto != null && !mensagemTexto.trim().isEmpty()) {
                            MensagemDTO mensagem = new MensagemDTO();
                            mensagem.setMensagem(mensagemTexto);
                            // Implementar lógica para determinar quem enviou
                            mensagem.setEhPaciente(true); // Placeholder
                            mensagem.setHoraEnvio(new Date()); // Placeholder
                            mensagens.add(mensagem);
                        }
                    }
                }

                rs.close();
                stmt.close();
                connection.close();

                mainHandler.post(() -> {
                    if (listener != null) {
                        listener.onMensagensCarregadas(mensagens);
                    }
                });

            } catch (SQLException e) {
                Log.e(TAG, "Erro ao carregar mensagens do banco", e);
                mainHandler.post(() -> {
                    if (listener != null) {
                        listener.onErro("Erro ao carregar mensagens");
                    }
                });
            }
        }).start();
    }

    public void indicarDigitando(boolean digitando) {
        try {
            JSONObject data = new JSONObject();
            data.put("digitando", digitando);
            data.put("usuario", usuarioLogado.getCpf());
            data.put("cpfPaciente", usuarioLogado.getCpf());
            data.put("funcionarioId", FUNCIONARIO_ID);

            mSocket.emit("digitando", data);

        } catch (JSONException e) {
            Log.e(TAG, "Erro ao indicar digitação", e);
        }
    }

    public boolean isConectado() {
        return mSocket != null && mSocket.connected();
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
}
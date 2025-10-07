package com.automacia.mobile.fragments;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.adapters.MensagemAdapter;
import com.automacia.mobile.models.MensagemDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.ChatManager;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

import java.util.List;

public class ChatFragment extends Fragment {

    private static final String TAG = "ChatFragment";
    private static final String CHANNEL_ID = "chat_notifications";
    private static final String ARG_USUARIO = "usuario";

    // Views
    private RecyclerView rvMensagens;
    private TextInputEditText etMensagem;
    private MaterialButton btnEnviar;
    private TextView tvStatusConexao;
    private ImageView ivStatusIndicator;
    private LinearLayout layoutDigitando;

    // Components
    private MensagemAdapter adapter;
    private ChatManager chatManager;
    private UsuarioDTO usuarioLogado;
    private NotificationManager notificationManager;

    // Controle de digitação
    private Handler digitandoHandler;
    private Runnable pararDigitando;
    private boolean estaDigitando = false;

    // Controle de estado
    private boolean isInitialized = false;
    private boolean shouldReconnectOnResume = false;
    private boolean mensagensCarregadas = false;

    public ChatFragment() {
        // Required empty public constructor
    }

    public static ChatFragment newInstance(UsuarioDTO usuario) {
        ChatFragment fragment = new ChatFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_USUARIO, usuario);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Inicializar handler
        digitandoHandler = new Handler(Looper.getMainLooper());

        // Carregar dados do usuário
        if (!carregarUsuarioArguments()) {
            Log.e(TAG, "Não foi possível carregar dados do usuário");
            return;
        }

        // Criar canal de notificação
        criarCanalNotificacao();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_chat, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (usuarioLogado == null) {
            mostrarErroUsuario();
            return;
        }

        inicializarViews(view);
        configurarRecyclerView();
        configurarListeners();
        inicializarChatManager();

        isInitialized = true;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        isInitialized = false;

        // Limpar callbacks pendentes
        if (digitandoHandler != null && pararDigitando != null) {
            digitandoHandler.removeCallbacks(pararDigitando);
            pararDigitando = null;
        }
    }

    private boolean carregarUsuarioArguments() {
        if (getArguments() != null) {
            usuarioLogado = (UsuarioDTO) getArguments().getSerializable(ARG_USUARIO);
            return usuarioLogado != null && isUsuarioValido(usuarioLogado);
        }
        return false;
    }

    private boolean isUsuarioValido(UsuarioDTO usuario) {
        return usuario != null &&
                usuario.getCpf() != null &&
                !usuario.getCpf().trim().isEmpty() &&
                usuario.getNome() != null &&
                !usuario.getNome().trim().isEmpty();
    }

    private void inicializarViews(View view) {
        rvMensagens = view.findViewById(R.id.rvMensagens);
        etMensagem = view.findViewById(R.id.etMensagem);
        btnEnviar = view.findViewById(R.id.btnEnviar);
        tvStatusConexao = view.findViewById(R.id.tvStatusConexao);
        ivStatusIndicator = view.findViewById(R.id.ivStatusIndicator);
        layoutDigitando = view.findViewById(R.id.layoutDigitando);
    }

    private void configurarRecyclerView() {
        adapter = new MensagemAdapter();
        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        layoutManager.setStackFromEnd(true);

        rvMensagens.setLayoutManager(layoutManager);
        rvMensagens.setAdapter(adapter);
    }

    private void configurarListeners() {
        // Botão enviar
        btnEnviar.setOnClickListener(v -> enviarMensagem());

        // Enter para enviar
        etMensagem.setOnEditorActionListener((v, actionId, event) -> {
            enviarMensagem();
            return true;
        });

        // Indicador de digitação
        etMensagem.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                gerenciarIndicadorDigitacao(s);
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void gerenciarIndicadorDigitacao(CharSequence texto) {
        boolean temTexto = texto.length() > 0;

        // Só enviar se mudou o estado
        if (temTexto && !estaDigitando) {
            estaDigitando = true;
            if (isChatManagerReady()) {
                chatManager.indicarDigitando(true);
            }
        }

        // Cancelar timer anterior
        if (pararDigitando != null) {
            digitandoHandler.removeCallbacks(pararDigitando);
        }

        // Criar novo timer se há texto
        if (temTexto) {
            pararDigitando = () -> {
                if (estaDigitando) {
                    estaDigitando = false;
                    if (isChatManagerReady()) {
                        chatManager.indicarDigitando(false);
                    }
                }
            };
            digitandoHandler.postDelayed(pararDigitando, 2000);
        } else if (estaDigitando) {
            // Se não há texto e estava digitando, parar imediatamente
            estaDigitando = false;
            if (isChatManagerReady()) {
                chatManager.indicarDigitando(false);
            }
        }
    }

    private void inicializarChatManager() {
        try {
            chatManager = new ChatManager(getContext(), usuarioLogado);
            configurarChatManagerListeners();

            // Conectar e carregar mensagens
            conectarChat();

        } catch (Exception e) {
            Log.e(TAG, "Erro ao inicializar ChatManager", e);
            mostrarErro(ChatManager.ErrorType.SOCKET, "Erro ao inicializar chat");
        }
    }

    private void configurarChatManagerListeners() {
        // Listener para mensagens recebidas - adiciona automaticamente
        chatManager.setOnMensagemRecebidaListener(mensagem -> {
            Log.d(TAG, "isFragmentReady: " + isFragmentReady());

            if (isFragmentReady()) {
                Log.d(TAG, "Mensagem recebida: " + mensagem.getMensagem() +
                        " | Paciente: " + mensagem.isEhPaciente());

                // Adicionar no adapter - SEMPRE
                adapter.adicionarMensagem(mensagem);
                rolarParaUltimaMensagem();

                // Notificar apenas se não é do próprio usuário
                if (!mensagem.isEhPaciente() ||
                        !usuarioLogado.getCpf().equals(mensagem.getPacienteCpf())) {
                    mostrarNotificacao(mensagem);
                }
            }
        });

        // Listener para status de conexão
        chatManager.setOnStatusConexaoListener(conectado -> {
            if (isFragmentReady()) {
                atualizarStatusConexao(conectado);

                // Tentar carregar mensagens quando conectar
                if (conectado && !mensagensCarregadas) {
                    carregarMensagens();
                }
            }
        });

        // Listener para digitação
        chatManager.setOnDigitandoListener((digitando, usuario) -> {
            if (isFragmentReady()) {
                // Só mostrar se não é o próprio usuário
                boolean mostrarIndicador = digitando &&
                        !usuarioLogado.getCpf().equals(usuario);

                layoutDigitando.setVisibility(
                        mostrarIndicador ? View.VISIBLE : View.GONE
                );

                Log.d(TAG, "Indicador digitação: " + digitando +
                        " para usuário: " + usuario +
                        " (mostrar: " + mostrarIndicador + ")");
            }
        });
    }

    private void conectarChat() {
        if (isChatManagerReady()) {
            chatManager.conectar();
        }
    }

    private void enviarMensagem() {
        String mensagem = etMensagem.getText().toString().trim();

        if (mensagem.isEmpty()) {
            mostrarToast("Digite uma mensagem");
            return;
        }

        if (!isChatManagerReady() || !chatManager.isConectado()) {
            mostrarToast("Não conectado ao servidor. Tentando reconectar...");
            conectarChat();
            return;
        }

        // Desabilitar botão e limpar campo
        setBotaoEnviarEnabled(false);
        etMensagem.getText().clear();

        // Enviar para servidor - mensagem aparecerá via onMensagemRecebida
        chatManager.enviarMensagem(mensagem, new ChatManager.OnMensagemEnviadaListener() {
            @Override
            public void onSucesso(MensagemDTO mensagem) {
                if (isFragmentReady()) {
                    setBotaoEnviarEnabled(true);
                    Log.d(TAG, "Mensagem enviada com sucesso: " + mensagem.getMensagem());
                    // NÃO adiciona no adapter aqui - aguarda confirmação do servidor
                }
            }

            @Override
            public void onErro(ChatManager.ErrorType tipo, String erro) {
                if (isFragmentReady()) {
                    setBotaoEnviarEnabled(true);

                    Log.e(TAG, "Erro ao enviar - Tipo: " + tipo.getValue() +
                            " - Erro: " + erro);

                    // Mostrar mensagem específica para o usuário
                    String mensagemUsuario = obterMensagemErroEnvio(tipo);
                    mostrarToast(mensagemUsuario);

                    // Restaurar texto se erro crítico
                    if (shouldRestoreMessage(tipo)) {
                        etMensagem.setText(mensagem);
                        etMensagem.setSelection(mensagem.length());
                    }
                }
            }
        });
    }

    private boolean shouldRestoreMessage(ChatManager.ErrorType tipo) {
        // Restaurar texto apenas em erros temporários
        return tipo == ChatManager.ErrorType.SOCKET ||
                tipo == ChatManager.ErrorType.TIMEOUT;
    }

    private String obterMensagemErroEnvio(ChatManager.ErrorType tipo) {
        switch (tipo) {
            case SOCKET:
                return "Problema de conexão. Tente novamente.";
            case BANCO:
                return "Erro no servidor. Tente mais tarde.";
            case TIMEOUT:
                return "Tempo limite. Verifique sua internet.";
            case VALIDACAO:
                return "Mensagem inválida.";
            default:
                return "Erro ao enviar. Tente novamente.";
        }
    }

    private void carregarMensagens() {
        if (!isChatManagerReady() || mensagensCarregadas) {
            return;
        }

        Log.d(TAG, "Carregando mensagens do histórico...");

        chatManager.carregarMensagens(new ChatManager.OnMensagensCarregadasListener() {
            @Override
            public void onMensagensCarregadas(List<MensagemDTO> mensagens) {
                if (isFragmentReady()) {
                    adapter.definirMensagens(mensagens);
                    mensagensCarregadas = true;

                    if (!mensagens.isEmpty()) {
                        rolarParaUltimaMensagem();
                    }

                    Log.d(TAG, "Mensagens carregadas: " + mensagens.size());
                }
            }

            @Override
            public void onErro(ChatManager.ErrorType tipo, String erro) {
                if (isFragmentReady()) {
                    Log.e(TAG, "Erro ao carregar mensagens - Tipo: " +
                            tipo.getValue() + " - Erro: " + erro);

                    String mensagemUsuario = obterMensagemErroCarregamento(tipo);
                    mostrarToast(mensagemUsuario);

                    // Em alguns casos, tentar novamente
                    if (shouldRetryLoading(tipo)) {
                        scheduleRetryLoading();
                    }
                }
            }
        });
    }

    private String obterMensagemErroCarregamento(ChatManager.ErrorType tipo) {
        switch (tipo) {
            case SOCKET:
                return "Erro de conexão ao carregar histórico";
            case BANCO:
                return "Erro no servidor ao buscar mensagens";
            case TIMEOUT:
                return "Tempo limite ao carregar histórico";
            case VALIDACAO:
                return "Dados de usuário inválidos";
            default:
                return "Erro ao carregar histórico";
        }
    }

    private boolean shouldRetryLoading(ChatManager.ErrorType tipo) {
        return tipo == ChatManager.ErrorType.SOCKET ||
                tipo == ChatManager.ErrorType.TIMEOUT;
    }

    private void scheduleRetryLoading() {
        digitandoHandler.postDelayed(() -> {
            if (isFragmentReady() && !mensagensCarregadas) {
                Log.d(TAG, "Tentando recarregar mensagens...");
                carregarMensagens();
            }
        }, 3000); // Retry após 3 segundos
    }

    private void rolarParaUltimaMensagem() {
        if (adapter != null && adapter.getItemCount() > 0) {
            rvMensagens.smoothScrollToPosition(adapter.getItemCount() - 1);
        }
    }

    private void atualizarStatusConexao(boolean conectado) {
        if (tvStatusConexao == null || ivStatusIndicator == null) {
            return;
        }

        if (conectado) {
            tvStatusConexao.setText("Online");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                ivStatusIndicator.setBackgroundTintList(
                        getResources().getColorStateList(R.color.success, null));
            }
            shouldReconnectOnResume = false;
        } else {
            tvStatusConexao.setText("Desconectado");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                ivStatusIndicator.setBackgroundTintList(
                        getResources().getColorStateList(R.color.danger, null));
            }
            shouldReconnectOnResume = true;
        }

        Log.d(TAG, "Status conexão: " + (conectado ? "Online" : "Desconectado"));
    }

    private void setBotaoEnviarEnabled(boolean enabled) {
        if (btnEnviar != null) {
            btnEnviar.setEnabled(enabled);
        }
    }

    private void mostrarToast(String mensagem) {
        if (getContext() != null) {
            Toast.makeText(getContext(), mensagem, Toast.LENGTH_SHORT).show();
        }
    }

    private void mostrarErro(ChatManager.ErrorType tipo, String mensagem) {
        Log.e(TAG, tipo.getValue() + ": " + mensagem);
        mostrarToast("Erro: " + mensagem);
    }

    private void mostrarErroUsuario() {
        mostrarToast("Dados do usuário inválidos. Faça login novamente.");
    }

    private void criarCanalNotificacao() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && getActivity() != null) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Mensagens do Chat",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            channel.setDescription("Notificações de novas mensagens no chat");

            notificationManager = getActivity().getSystemService(NotificationManager.class);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
    }

    private void mostrarNotificacao(MensagemDTO mensagem) {
        // Só mostrar se fragment não está visível
        if (!isVisible() || !getUserVisibleHint()) {
            if (getContext() != null && notificationManager != null) {
                NotificationCompat.Builder builder = new NotificationCompat.Builder(getContext(), CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_chat)
                        .setContentTitle("Nova mensagem")
                        .setContentText(mensagem.getMensagem())
                        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                        .setAutoCancel(true);

                notificationManager.notify(1, builder.build());
            }
        }
    }

    // Métodos de verificação de estado
    private boolean isFragmentReady() {
        return isInitialized && isAdded() && getContext() != null;
    }

    private boolean isChatManagerReady() {
        return chatManager != null && isFragmentReady();
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG, "onResume");

        // Só reconectar se necessário
        if (shouldReconnectOnResume && isChatManagerReady()) {
            Log.d(TAG, "Reconectando chat...");
            conectarChat();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        Log.d(TAG, "onPause");

        // Parar digitação
        pararIndicadorDigitacao();
    }

    private void pararIndicadorDigitacao() {
        if (estaDigitando && isChatManagerReady()) {
            estaDigitando = false;
            chatManager.indicarDigitando(false);

            if (pararDigitando != null) {
                digitandoHandler.removeCallbacks(pararDigitando);
            }
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy - limpando recursos");

        // Limpar digitação
        pararIndicadorDigitacao();

        // Limpar handlers
        if (digitandoHandler != null) {
            digitandoHandler.removeCallbacksAndMessages(null);
        }

        // Destruir ChatManager
        if (chatManager != null) {
            chatManager.destroy();
            chatManager = null;
        }

        // Reset state
        mensagensCarregadas = false;
        shouldReconnectOnResume = false;

        Log.d(TAG, "ChatFragment totalmente limpo");
    }
}
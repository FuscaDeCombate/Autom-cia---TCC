package com.automacia.mobile.fragments;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Intent;
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

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.quickactions.FuncionarioChat;
import com.automacia.mobile.adapters.MensagemAdapter;
import com.automacia.mobile.models.FuncionarioChatDTO;
import com.automacia.mobile.models.MensagemDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.managers.ChatManager;
import com.automacia.mobile.utils.ChatPreferences;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

import java.util.List;

public class ChatFragment extends Fragment {

    private static final String TAG = "ChatFragment";
    private static final String CHANNEL_ID = "chat_notifications";
    private static final String ARG_USUARIO = "usuario";
    private static final String ARG_FUNCIONARIO = "funcionario";

    // Views
    private RecyclerView rvMensagens;
    private TextInputEditText etMensagem;
    private MaterialButton btnEnviar;
    private MaterialButton btnSelecionarFuncionario;
    private TextView tvStatusConexao;
    private TextView tvFuncionarioNome;
    private ImageView ivStatusIndicator;
    private LinearLayout layoutDigitando;
    private LinearLayout layoutEmptyState;
    private LinearLayout layoutChatPrincipal;

    // Components
    private MensagemAdapter adapter;
    private ChatManager chatManager;
    private UsuarioDTO usuarioLogado;
    private FuncionarioChatDTO funcionarioAtual;
    private NotificationManager notificationManager;
    private ChatPreferences chatPreferences;

    // Controle de digitação
    private Handler digitandoHandler;
    private Runnable pararDigitando;
    private boolean estaDigitando = false;

    // Controle de estado
    private boolean isInitialized = false;
    private boolean shouldReconnectOnResume = false;
    private boolean mensagensCarregadas = false;
    private boolean isTrocandoFuncionario = false;

    // ActivityResultLauncher para selecionar funcionário
    private ActivityResultLauncher<Intent> selecionarFuncionarioLauncher;

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

    public static ChatFragment newInstance(UsuarioDTO usuario, FuncionarioChatDTO funcionario) {
        ChatFragment fragment = new ChatFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_USUARIO, usuario);
        args.putSerializable(ARG_FUNCIONARIO, funcionario);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Inicializar handler e preferências
        digitandoHandler = new Handler(Looper.getMainLooper());
        chatPreferences = new ChatPreferences(requireContext());

        // Carregar dados do usuário
        if (!carregarUsuarioArguments()) {
            Log.e(TAG, "Não foi possível carregar dados do usuário");
            return;
        }

        // Registrar launcher para seleção de funcionário
        registrarActivityResultLauncher();

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

        isInitialized = true;

        // Verificar se tem funcionário (via args ou SharedPreferences)
        verificarEInicializarChat();
    }

    private void registrarActivityResultLauncher() {
        selecionarFuncionarioLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
                        FuncionarioChatDTO funcionarioSelecionado =
                                (FuncionarioChatDTO) result.getData().getSerializableExtra("funcionario");

                        if (funcionarioSelecionado != null) {
                            Log.d(TAG, "Funcionário selecionado: " + funcionarioSelecionado.getNomeFuncionario());
                            processarNovoFuncionario(funcionarioSelecionado);
                        }
                    }
                }
        );
    }

    private void processarNovoFuncionario(FuncionarioChatDTO novoFuncionario) {
        // Validar funcionário
        if (!isFuncionarioValido(novoFuncionario)) {
            mostrarToast("Dados do funcionário inválidos");
            return;
        }

        // Verificar se é o mesmo funcionário
        if (funcionarioAtual != null &&
                funcionarioAtual.getFuncionarioRec().equals(novoFuncionario.getFuncionarioRec())) {
            Log.d(TAG, "Mesmo funcionário selecionado, ignorando...");
            return;
        }

        // Caso 1: Primeiro funcionário (chat ainda não inicializado)
        if (funcionarioAtual == null) {
            funcionarioAtual = novoFuncionario;
            chatPreferences.salvarUltimoFuncionario(novoFuncionario);

            ocultarEmptyState();
            inicializarChatManager();

        } else {
            // Caso 2: Trocar de funcionário
            trocarFuncionario(novoFuncionario);
        }
    }

    private void trocarFuncionario(FuncionarioChatDTO novoFuncionario) {
        if (!isChatManagerReady() || isTrocandoFuncionario) {
            Log.w(TAG, "ChatManager não está pronto ou já está trocando funcionário");
            return;
        }

        isTrocandoFuncionario = true;
        mostrarToast("Conectando com " + novoFuncionario.getNomeFuncionario() + "...");

        final FuncionarioChatDTO funcionarioAntigo = funcionarioAtual;

        try {
            int novoFuncionarioId = Integer.parseInt(novoFuncionario.getFuncionarioRec());

            chatManager.trocarFuncionario(novoFuncionarioId,
                    new ChatManager.OnTrocaFuncionarioListener() {
                        @Override
                        public void onTrocaSucesso(int antigoId, int novoId) {
                            if (!isFragmentReady()) return;

                            Log.d(TAG, "Troca de funcionário bem-sucedida: " + antigoId + " → " + novoId);

                            // Atualizar funcionário atual
                            funcionarioAtual = novoFuncionario;
                            chatPreferences.salvarUltimoFuncionario(novoFuncionario);

                            // Atualizar UI
                            atualizarHeaderFuncionario();

                            // Limpar mensagens antigas
                            adapter.limparMensagens();
                            mensagensCarregadas = false;

                            // Carregar mensagens do novo funcionário
                            carregarMensagens();

                            isTrocandoFuncionario = false;
                            mostrarToast("Conectado com " + novoFuncionario.getNomeFuncionario());
                        }

                        @Override
                        public void onTrocaErro(ChatManager.ErrorType tipo, String mensagem) {
                            if (!isFragmentReady()) return;

                            Log.e(TAG, "Erro ao trocar funcionário: " + mensagem);
                            isTrocandoFuncionario = false;

                            mostrarToast("Erro ao conectar: " + mensagem);

                            // Se erro crítico, manter funcionário antigo
                            if (tipo == ChatManager.ErrorType.VALIDACAO) {
                                funcionarioAtual = funcionarioAntigo;
                            }
                        }
                    });

        } catch (NumberFormatException e) {
            Log.e(TAG, "ID de funcionário inválido: " + novoFuncionario.getFuncionarioRec(), e);
            isTrocandoFuncionario = false;
            mostrarToast("Erro: ID de funcionário inválido");
        }
    }

    private void verificarEInicializarChat() {
        // Prioridade 1: Funcionário via Arguments
        if (getArguments() != null && getArguments().containsKey(ARG_FUNCIONARIO)) {
            funcionarioAtual = (FuncionarioChatDTO) getArguments().getSerializable(ARG_FUNCIONARIO);

            if (isFuncionarioValido(funcionarioAtual)) {
                Log.d(TAG, "Funcionário carregado via Arguments: " + funcionarioAtual.getNomeFuncionario());
                chatPreferences.salvarUltimoFuncionario(funcionarioAtual);
                ocultarEmptyState();
                inicializarChatManager();
                return;
            }
        }

        // Prioridade 2: Último funcionário salvo
        FuncionarioChatDTO ultimoFuncionario = chatPreferences.getUltimoFuncionario();
        if (ultimoFuncionario != null && isFuncionarioValido(ultimoFuncionario)) {
            Log.d(TAG, "Último funcionário carregado: " + ultimoFuncionario.getNomeFuncionario());
            funcionarioAtual = ultimoFuncionario;
            ocultarEmptyState();
            inicializarChatManager();
            return;
        }

        // Nenhum funcionário: mostrar Empty State
        Log.d(TAG, "Nenhum funcionário selecionado - mostrando Empty State");
        mostrarEmptyState();
    }

    private boolean isFuncionarioValido(FuncionarioChatDTO funcionario) {
        if (funcionario == null) return false;

        String id = funcionario.getFuncionarioRec();
        if (id == null || id.trim().isEmpty()) return false;

        try {
            int numId = Integer.parseInt(id);
            return numId > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private void mostrarEmptyState() {
        if (layoutEmptyState != null && layoutChatPrincipal != null) {
            layoutEmptyState.setVisibility(View.VISIBLE);
            layoutChatPrincipal.setVisibility(View.GONE);
        }
    }

    private void ocultarEmptyState() {
        if (layoutEmptyState != null && layoutChatPrincipal != null) {
            layoutEmptyState.setVisibility(View.GONE);
            layoutChatPrincipal.setVisibility(View.VISIBLE);
        }
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
        // Views principais
        rvMensagens = view.findViewById(R.id.rvMensagens);
        etMensagem = view.findViewById(R.id.etMensagem);
        btnEnviar = view.findViewById(R.id.btnEnviar);
        tvStatusConexao = view.findViewById(R.id.tvStatusConexao);
        tvFuncionarioNome = view.findViewById(R.id.tvFuncionarioNome);
        ivStatusIndicator = view.findViewById(R.id.ivStatusIndicator);
        layoutDigitando = view.findViewById(R.id.layoutDigitando);

        // Layouts de estado
        layoutEmptyState = view.findViewById(R.id.layoutEmptyState);
        layoutChatPrincipal = view.findViewById(R.id.layoutChatPrincipal);

        // Botão do Empty State
        btnSelecionarFuncionario = view.findViewById(R.id.btnSelecionarFuncionario);
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

        // Botão selecionar funcionário (Empty State)
        btnSelecionarFuncionario.setOnClickListener(v -> abrirSelecaoFuncionario());

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

    private void abrirSelecaoFuncionario() {
        Intent intent = new Intent(getActivity(), FuncionarioChat.class);
        intent.putExtra("usuario", usuarioLogado);
        intent.putExtra("modo_selecao", true);
        selecionarFuncionarioLauncher.launch(intent);
    }

    private void gerenciarIndicadorDigitacao(CharSequence texto) {
        boolean temTexto = texto.length() > 0;

        if (temTexto && !estaDigitando) {
            estaDigitando = true;
            if (isChatManagerReady()) {
                chatManager.indicarDigitando(true);
            }
        }

        if (pararDigitando != null) {
            digitandoHandler.removeCallbacks(pararDigitando);
        }

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
            estaDigitando = false;
            if (isChatManagerReady()) {
                chatManager.indicarDigitando(false);
            }
        }
    }

    private void inicializarChatManager() {
        try {
            if (funcionarioAtual == null || !isFuncionarioValido(funcionarioAtual)) {
                Log.e(TAG, "Tentativa de inicializar ChatManager sem funcionário válido");
                return;
            }

            Log.d(TAG, "Inicializando ChatManager - Usuário: " + usuarioLogado.getNome() +
                    ", Funcionário: " + funcionarioAtual.getNomeFuncionario());

            // Atualizar header
            atualizarHeaderFuncionario();

            // Criar ChatManager com funcionário
            chatManager = new ChatManager(
                    getContext(),
                    usuarioLogado,
                    Integer.parseInt(funcionarioAtual.getFuncionarioRec())
            );

            configurarChatManagerListeners();

            // Delay para garantir inicialização completa
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                if (isFragmentReady()) {
                    Log.d(TAG, "Conectando ao chat...");
                    conectarChat();
                }
            }, 100);

        } catch (Exception e) {
            Log.e(TAG, "Erro ao inicializar ChatManager", e);
            mostrarErro(ChatManager.ErrorType.SOCKET, "Erro ao inicializar chat");
        }
    }

    private void atualizarHeaderFuncionario() {
        if (tvFuncionarioNome != null && funcionarioAtual != null) {
            String nome = funcionarioAtual.getNomeFuncionario();
            String tipo = funcionarioAtual.getTipoFuncionario();

            String displayName = nome;
            if (tipo != null && !tipo.isEmpty()) {
                displayName = nome + " - " + tipo;
            }

            tvFuncionarioNome.setText(displayName);
        }
    }

    private void configurarChatManagerListeners() {
        chatManager.setOnMensagemRecebidaListener(mensagem -> {
            Log.d(TAG, "Mensagem recebida: " + mensagem.getMensagem());

            if (isFragmentReady()) {
                adapter.adicionarMensagem(mensagem);
                rolarParaUltimaMensagem();

                if (!mensagem.isEhPaciente() ||
                        !usuarioLogado.getCpf().equals(mensagem.getPacienteCpf())) {
                    mostrarNotificacao(mensagem);
                }
            }
        });

        chatManager.setOnStatusConexaoListener(conectado -> {
            Log.d(TAG, "Status de conexão: " + conectado);

            if (isFragmentReady()) {
                atualizarStatusConexao(conectado);

                if (conectado && !mensagensCarregadas) {
                    Log.d(TAG, "Conectado! Carregando mensagens...");
                    carregarMensagens();
                } else if (!conectado) {
                    Log.w(TAG, "Desconectado do servidor");
                }
            }
        });

        chatManager.setOnDigitandoListener((digitando, usuario) -> {
            if (isFragmentReady()) {
                boolean mostrarIndicador = digitando &&
                        !usuarioLogado.getCpf().equals(usuario);

                layoutDigitando.setVisibility(
                        mostrarIndicador ? View.VISIBLE : View.GONE
                );
            }
        });

        Log.d(TAG, "Listeners configurados");
    }

    private void conectarChat() {
        if (!isChatManagerReady()) {
            Log.e(TAG, "ChatManager não está pronto para conectar");
            return;
        }

        Log.d(TAG, "Chamando chatManager.conectar()");
        chatManager.conectar();
    }

    private void enviarMensagem() {
        String mensagem = etMensagem.getText().toString().trim();

        if (mensagem.isEmpty()) {
            mostrarToast("Digite uma mensagem");
            return;
        }

        if (!isChatManagerReady() || !chatManager.isConectado()) {
            mostrarToast("Não conectado. Tentando reconectar...");
            conectarChat();
            return;
        }

        setBotaoEnviarEnabled(false);
        etMensagem.getText().clear();

        chatManager.enviarMensagem(mensagem, new ChatManager.OnMensagemEnviadaListener() {
            @Override
            public void onSucesso(MensagemDTO mensagem) {
                if (isFragmentReady()) {
                    setBotaoEnviarEnabled(true);
                    Log.d(TAG, "Mensagem enviada com sucesso");
                }
            }

            @Override
            public void onErro(ChatManager.ErrorType tipo, String erro) {
                if (isFragmentReady()) {
                    setBotaoEnviarEnabled(true);
                    Log.e(TAG, "Erro ao enviar: " + erro);

                    String mensagemUsuario = obterMensagemErroEnvio(tipo);
                    mostrarToast(mensagemUsuario);

                    if (shouldRestoreMessage(tipo)) {
                        etMensagem.setText(mensagem);
                        etMensagem.setSelection(mensagem.length());
                    }
                }
            }
        });
    }

    private boolean shouldRestoreMessage(ChatManager.ErrorType tipo) {
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
                    Log.e(TAG, "Erro ao carregar mensagens: " + erro);

                    String mensagemUsuario = obterMensagemErroCarregamento(tipo);
                    mostrarToast(mensagemUsuario);

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
        }, 3000);
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

    /**
     * Metodo público para atualizar o funcionário externamente
     * Usado quando a MainActivity recebe uma Intent com funcionário
     */
    public void atualizarFuncionario(FuncionarioChatDTO novoFuncionario) {
        if (!isAdded() || getContext() == null) {
            Log.w(TAG, "Fragment não está anexado, salvando funcionário para depois");
            chatPreferences.salvarUltimoFuncionario(novoFuncionario);
            return;
        }

        Log.d(TAG, "Atualizando funcionário via método público: " +
                novoFuncionario.getNomeFuncionario());

        processarNovoFuncionario(novoFuncionario);
    }

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

        // Se não tem funcionário, não faz nada
        if (funcionarioAtual == null) {
            return;
        }

        // Verificar se funcionário mudou via SharedPreferences
        FuncionarioChatDTO ultimoFuncionario = chatPreferences.getUltimoFuncionario();
        if (ultimoFuncionario != null &&
                !funcionarioAtual.getFuncionarioRec().equals(ultimoFuncionario.getFuncionarioRec())) {

            Log.d(TAG, "Funcionário mudou - trocando...");
            processarNovoFuncionario(ultimoFuncionario);
            return;
        }

        // Reconectar se necessário
        if (isChatManagerReady()) {
            if (shouldReconnectOnResume || !chatManager.isConectado()) {
                Log.d(TAG, "Reconectando chat...");
                conectarChat();
            }
        }
    }

    @Override
    public void onPause() {
        super.onPause();
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
        Log.d(TAG, "onDestroy");

        pararIndicadorDigitacao();

        if (digitandoHandler != null) {
            digitandoHandler.removeCallbacksAndMessages(null);
        }

        if (chatManager != null) {
            chatManager.destroy();
            chatManager = null;
        }

        mensagensCarregadas = false;
        shouldReconnectOnResume = false;

        Log.d(TAG, "ChatFragment totalmente limpo");
    }
}
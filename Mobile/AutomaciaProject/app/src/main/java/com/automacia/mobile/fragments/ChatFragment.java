package com.automacia.mobile.fragments;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
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
    private Handler digitandoHandler = new Handler();
    private Runnable pararDigitando;
    private boolean estaDigitando = false;

    public ChatFragment() {
        // Required empty public constructor
    }

    public static ChatFragment newInstance() {
        return new ChatFragment();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Carregar dados do usuário logado
        carregarUsuarioLogado();

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

        inicializarViews(view);
        configurarRecyclerView();
        configurarListeners();
        inicializarChatManager();
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
        layoutManager.setStackFromEnd(true); // Começar do final da lista

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
                if (!estaDigitando && s.length() > 0) {
                    estaDigitando = true;
                    if (chatManager != null) {
                        chatManager.indicarDigitando(true);
                    }
                }

                // Cancelar o timer anterior
                if (pararDigitando != null) {
                    digitandoHandler.removeCallbacks(pararDigitando);
                }

                // Criar novo timer para parar de digitar
                pararDigitando = () -> {
                    estaDigitando = false;
                    if (chatManager != null) {
                        chatManager.indicarDigitando(false);
                    }
                };

                digitandoHandler.postDelayed(pararDigitando, 2000); // 2 segundos
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void inicializarChatManager() {
        if (usuarioLogado != null) {
            chatManager = new ChatManager(getContext(), usuarioLogado);

            // Configurar listeners
            chatManager.setOnMensagemRecebidaListener(mensagem -> {
                adapter.adicionarMensagem(mensagem);
                rolarParaUltimaMensagem();
                mostrarNotificacao(mensagem);
            });

            chatManager.setOnStatusConexaoListener(conectado -> {
                atualizarStatusConexao(conectado);
            });

            chatManager.setOnDigitandoListener(digitando -> {
                layoutDigitando.setVisibility(digitando ? View.VISIBLE : View.GONE);
            });

            // Conectar e carregar mensagens
            chatManager.conectar();
            carregarMensagens();
        }
    }

    private void enviarMensagem() {
        String mensagem = etMensagem.getText().toString().trim();

        if (mensagem.isEmpty()) {
            Toast.makeText(getContext(), "Digite uma mensagem", Toast.LENGTH_SHORT).show();
            return;
        }

        if (chatManager == null || !chatManager.isConectado()) {
            Toast.makeText(getContext(), "Não conectado ao servidor", Toast.LENGTH_SHORT).show();
            return;
        }

        // Desabilitar botão enquanto envia
        btnEnviar.setEnabled(false);

        // Adicionar mensagem localmente primeiro
        MensagemDTO mensagemLocal = new MensagemDTO(mensagem, true);
        adapter.adicionarMensagem(mensagemLocal);
        rolarParaUltimaMensagem();

        // Limpar campo
        etMensagem.getText().clear();

        // Enviar para servidor
        chatManager.enviarMensagem(mensagem, new ChatManager.OnMensagemEnviadaListener() {
            @Override
            public void onSucesso(String resposta) {
                btnEnviar.setEnabled(true);
                Log.d(TAG, "Mensagem enviada: " + resposta);
            }

            @Override
            public void onErro(String erro) {
                btnEnviar.setEnabled(true);
                Toast.makeText(getContext(), "Erro ao enviar: " + erro, Toast.LENGTH_SHORT).show();
                // TODO: Marcar mensagem como falha ou remover
            }
        });
    }

    private void carregarMensagens() {
        if (chatManager != null) {
            chatManager.carregarMensagens(new ChatManager.OnMensagensCarregadasListener() {
                @Override
                public void onMensagensCarregadas(List<MensagemDTO> mensagens) {
                    adapter.definirMensagens(mensagens);
                    if (!mensagens.isEmpty()) {
                        rolarParaUltimaMensagem();
                    }
                }

                @Override
                public void onErro(String erro) {
                    if (isAdded()) {
                        requireActivity().runOnUiThread(() ->
                            Toast.makeText(getContext(), "Erro ao carregar mensagens: " + erro,
                                    Toast.LENGTH_SHORT).show()
                        );
                    }
                }
            });
        }
    }

    private void rolarParaUltimaMensagem() {
        if (adapter.getItemCount() > 0) {
            rvMensagens.smoothScrollToPosition(adapter.getItemCount() - 1);
        }
    }

    private void atualizarStatusConexao(boolean conectado) {
        if (tvStatusConexao != null && ivStatusIndicator != null) {
            if (conectado) {
                tvStatusConexao.setText("Online");
                ivStatusIndicator.setBackgroundTintList(
                        getResources().getColorStateList(R.color.success, null));
            } else {
                tvStatusConexao.setText("Desconectado");
                ivStatusIndicator.setBackgroundTintList(
                        getResources().getColorStateList(R.color.danger, null));
            }
        }
    }

    private void carregarUsuarioLogado() {
        // Carregar dados do SharedPreferences ou de onde você armazena os dados do login
        SharedPreferences prefs = getActivity().getSharedPreferences("user_data", Context.MODE_PRIVATE);

        usuarioLogado = new UsuarioDTO();
        usuarioLogado.setCpf(prefs.getString("cpf", ""));
        usuarioLogado.setNome(prefs.getString("nome", ""));
        usuarioLogado.setEmail(prefs.getString("email", ""));
        usuarioLogado.setTelefone(prefs.getString("telefone", ""));

        if (usuarioLogado.getCpf().isEmpty()) {
            Toast.makeText(getContext(), "Usuário não encontrado. Faça login novamente.",
                    Toast.LENGTH_LONG).show();
            // TODO: Redirecionar para tela de login
        }
    }

    private void criarCanalNotificacao() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Mensagens do Chat",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            channel.setDescription("Notificações de novas mensagens no chat");

            notificationManager = getActivity().getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private void mostrarNotificacao(MensagemDTO mensagem) {
        // Só mostrar se o app estiver em background ou fragment não visível
        if (!isVisible() || !getUserVisibleHint()) {
            NotificationCompat.Builder builder = new NotificationCompat.Builder(getContext(), CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_chat)
                    .setContentTitle("Nova mensagem")
                    .setContentText(mensagem.getMensagem())
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                    .setAutoCancel(true);

            if (notificationManager != null) {
                notificationManager.notify(1, builder.build());
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (chatManager != null) {
            chatManager.conectar();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        // Parar indicador de digitação
        if (estaDigitando && chatManager != null) {
            estaDigitando = false;
            chatManager.indicarDigitando(false);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (chatManager != null) {
            chatManager.limparListeners();
            chatManager.desconectar();
        }
        if (digitandoHandler != null && pararDigitando != null) {
            digitandoHandler.removeCallbacks(pararDigitando);
        }
    }
}
package com.automacia.mobile.quickactions;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.MainActivity;
import com.automacia.mobile.R;
import com.automacia.mobile.adapters.FuncionarioChatAdapter;
import com.automacia.mobile.models.FuncionarioChatDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.FuncionarioChatService;
import com.automacia.mobile.utils.ChatPreferences;
import com.google.android.material.chip.Chip;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.util.ArrayList;
import java.util.List;

public class FuncionarioChat extends AppCompatActivity {

    private static final String TAG = "FuncionarioChat";
    private static final String EXTRA_USUARIO = "usuario";
    private static final String EXTRA_MODO_SELECAO = "modo_selecao";

    // Views
    private ImageButton btnVoltar;
    private EditText etBuscar;
    private ImageButton btnLimparBusca;
    private RecyclerView recyclerViewFuncionarios;
    private LinearLayout emptyState;
    private LinearLayout loadingState;
    private TextView tvContador;
    private FloatingActionButton fabAtualizar;

    // Chips de filtro
    private Chip chipTodos;
    private Chip chipMedicos;
    private Chip chipFarmacias;
    private Chip chipChatAberto;

    // Adapter e dados
    private FuncionarioChatAdapter adapter;
    private List<FuncionarioChatDTO> listaOriginal;
    private List<FuncionarioChatDTO> listaFiltrada;

    // Service e usuário
    private FuncionarioChatService service;
    private UsuarioDTO usuarioLogado;

    // Filtro atual
    private String filtroAtual = "TODOS";

    // Modo de operacao
    private boolean modoSelecao = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_list_chat);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Recupera usuário da intent
        recuperarUsuario();
        verificarModoSelecao();

        // Inicializa componentes
        inicializarViews();
        inicializarRecyclerView();
        inicializarListeners();
        inicializarService();

        // Carrega dados
        carregarFuncionarios();
    }

    /**
     * Recupera o usuário logado da Intent
     */
    private void recuperarUsuario() {
        usuarioLogado = (UsuarioDTO) getIntent().getSerializableExtra(EXTRA_USUARIO);

        if (usuarioLogado == null) {
            Log.e(TAG, "Usuário não foi passado pela Intent");
            Toast.makeText(this, "Erro: Usuário não identificado", Toast.LENGTH_SHORT).show();
            finish();
        } else {
            Log.d(TAG, "Usuário recuperado: " + usuarioLogado.getCpf());
        }
    }

    /**
     * Verifica se foi aberto em modo seleção
     */
    private void verificarModoSelecao() {
        modoSelecao = getIntent().getBooleanExtra(EXTRA_MODO_SELECAO, false);
        Log.d(TAG, "Modo seleção: " + modoSelecao);
    }

    /**
     * Inicializa todas as views do layout
     */
    private void inicializarViews() {
        // Botões
        btnVoltar = findViewById(R.id.btnVoltar);
        btnLimparBusca = findViewById(R.id.btnLimparBusca);
        fabAtualizar = findViewById(R.id.fabAtualizar);

        // Campos de texto
        etBuscar = findViewById(R.id.etBuscar);
        tvContador = findViewById(R.id.tvContador);

        // RecyclerView e estados
        recyclerViewFuncionarios = findViewById(R.id.recyclerViewFuncionarios);
        emptyState = findViewById(R.id.emptyState);
        loadingState = findViewById(R.id.loadingState);

        // Chips de filtro
        chipTodos = findViewById(R.id.chipTodos);
        chipMedicos = findViewById(R.id.chipMedicos);
        chipFarmacias = findViewById(R.id.chipFarmacias);
        chipChatAberto = findViewById(R.id.chipChatAberto);

        // Inicializa listas
        listaOriginal = new ArrayList<>();
        listaFiltrada = new ArrayList<>();
    }

    /**
     * Configura o RecyclerView e o Adapter
     */
    private void inicializarRecyclerView() {
        adapter = new FuncionarioChatAdapter(funcionario -> {
            if (modoSelecao) {
                // MODO 1: Foi aberto pelo ChatFragment - retorna resultado
                retornarFuncionarioSelecionado(funcionario);
            } else {
                // MODO 2: Foi aberto de outro lugar - abre chat diretamente
                abrirChatComFuncionario(funcionario);
            }
        });

        recyclerViewFuncionarios.setLayoutManager(new LinearLayoutManager(this));
        recyclerViewFuncionarios.setAdapter(adapter);
        recyclerViewFuncionarios.setHasFixedSize(true);
    }

    /**
     * MODO 1: Retorna funcionário para quem chamou (ChatFragment)
     */
    private void retornarFuncionarioSelecionado(FuncionarioChatDTO funcionario) {
        Intent resultIntent = new Intent();
        resultIntent.putExtra("funcionario", funcionario);
        setResult(RESULT_OK, resultIntent);

        Toast.makeText(this,
                "Conectando com " + funcionario.getNomeFuncionario(),
                Toast.LENGTH_SHORT).show();

        finish();
    }

    /**
     * MODO 2: Abre MainActivity e navega para ChatFragment com funcionário
     */
    private void abrirChatComFuncionario(FuncionarioChatDTO funcionario) {
        // Salvar funcionário em SharedPreferences
        ChatPreferences prefs = new ChatPreferences(this);
        prefs.salvarUltimoFuncionario(funcionario);

        // Voltar para MainActivity e ir para aba do Chat
        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("navegar_para_chat", true); // Flag para MainActivity
        intent.putExtra("funcionario", funcionario);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);

        Toast.makeText(this,
                "Abrindo chat com " + funcionario.getNomeFuncionario(),
                Toast.LENGTH_SHORT).show();

        finish();
    }

    /**
     * Inicializa todos os listeners de eventos
     */
    private void inicializarListeners() {
        // Botão voltar
        btnVoltar.setOnClickListener(v -> finish());

        // Botão atualizar
        fabAtualizar.setOnClickListener(v -> {
            limparBusca();
            carregarFuncionarios();
        });

        // Busca em tempo real
        etBuscar.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                // Mostra/oculta botão de limpar
                btnLimparBusca.setVisibility(s.length() > 0 ? View.VISIBLE : View.GONE);

                // Aplica filtro de busca
                aplicarFiltros(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        // Botão limpar busca
        btnLimparBusca.setOnClickListener(v -> limparBusca());

        // Listeners dos chips
        chipTodos.setOnClickListener(v -> {
            if (chipTodos.isChecked()) {
                filtroAtual = "TODOS";
                aplicarFiltros(etBuscar.getText().toString());
            }
        });

        chipMedicos.setOnClickListener(v -> {
            if (chipMedicos.isChecked()) {
                filtroAtual = "MEDICOS";
                aplicarFiltros(etBuscar.getText().toString());
            }
        });

        chipFarmacias.setOnClickListener(v -> {
            if (chipFarmacias.isChecked()) {
                filtroAtual = "FARMACIAS";
                aplicarFiltros(etBuscar.getText().toString());
            }
        });

        chipChatAberto.setOnClickListener(v -> {
            if (chipChatAberto.isChecked()) {
                filtroAtual = "CHAT_ABERTO";
                aplicarFiltros(etBuscar.getText().toString());
            }
        });
    }

    /**
     * Inicializa o serviço de funcionários
     */
    private void inicializarService() {
        service = new FuncionarioChatService();
    }

    /**
     * Carrega a lista de funcionários do banco de dados
     */
    private void carregarFuncionarios() {
        if (usuarioLogado == null) {
            Log.e(TAG, "Não é possível carregar funcionários sem usuário logado");
            return;
        }

        mostrarLoading();

        service.buscarFuncionariosParaChat(usuarioLogado.getCpf(), new FuncionarioChatService.FuncionarioCallback() {
            @Override
            public void onSuccess(List<FuncionarioChatDTO> funcionarios) {
                // Executa na thread principal
                new Handler(Looper.getMainLooper()).post(() -> {
                    listaOriginal.clear();
                    listaOriginal.addAll(funcionarios);

                    aplicarFiltros(etBuscar.getText().toString());

                    esconderLoading();

                    Log.d(TAG, "Funcionários carregados com sucesso: " + funcionarios.size());
                });
            }

            @Override
            public void onError(String errorMessage) {
                // Executa na thread principal
                new Handler(Looper.getMainLooper()).post(() -> {
                    esconderLoading();
                    mostrarEmptyState();

                    Toast.makeText(FuncionarioChat.this,
                            "Erro ao carregar funcionários: " + errorMessage,
                            Toast.LENGTH_LONG).show();

                    Log.e(TAG, "Erro ao carregar funcionários: " + errorMessage);
                });
            }
        });
    }

    /**
     * Aplica os filtros de busca e categoria
     */
    private void aplicarFiltros(String textoBusca) {
        listaFiltrada.clear();

        for (FuncionarioChatDTO func : listaOriginal) {
            boolean passaFiltroCategoria = aplicarFiltroCategoria(func);
            boolean passaFiltroBusca = aplicarFiltroBusca(func, textoBusca);

            if (passaFiltroCategoria && passaFiltroBusca) {
                listaFiltrada.add(func);
            }
        }

        atualizarAdapter();
    }

    /**
     * Aplica o filtro de categoria (chip selecionado)
     */
    private boolean aplicarFiltroCategoria(FuncionarioChatDTO func) {
        switch (filtroAtual) {
            case "MEDICOS":
                return func.getTipoFuncionario() != null && (func.getTipoFuncionario().toLowerCase().contains("saúde"));

            case "FARMACIAS":
                return func.getTipoFuncionario() != null && (func.getTipoFuncionario().toLowerCase().contains("farmácia"));

            case "CHAT_ABERTO":
                return func.isChatAberto();

            case "TODOS":
            default:
                return true;
        }
    }

    /**
     * Aplica o filtro de busca por texto
     */
    private boolean aplicarFiltroBusca(FuncionarioChatDTO func, String textoBusca) {
        if (textoBusca == null || textoBusca.trim().isEmpty()) {
            return true;
        }

        String busca = textoBusca.toLowerCase().trim();

        boolean nomeContem = func.getNomeFuncionario() != null &&
                func.getNomeFuncionario().toLowerCase().contains(busca);

        boolean tipoContem = func.getTipoFuncionario() != null &&
                func.getTipoFuncionario().toLowerCase().contains(busca);

        boolean hospitalContem = func.getHospital() != null &&
                func.getHospital().toLowerCase().contains(busca);

        return nomeContem || tipoContem || hospitalContem;
    }

    /**
     * Atualiza o adapter com a lista filtrada
     */
    private void atualizarAdapter() {
        adapter.setFuncionarios(listaFiltrada);
        atualizarContador();

        if (listaFiltrada.isEmpty()) {
            mostrarEmptyState();
        } else {
            esconderEmptyState();
        }
    }

    /**
     * Atualiza o contador de resultados
     */
    private void atualizarContador() {
        int total = listaFiltrada.size();
        String texto;

        if (total == 0) {
            texto = "Nenhum profissional encontrado";
        } else if (total == 1) {
            texto = "1 profissional disponível";
        } else {
            texto = total + " profissionais disponíveis";
        }

        tvContador.setText(texto);
    }

    /**
     * Limpa o campo de busca
     */
    private void limparBusca() {
        etBuscar.setText("");
        etBuscar.clearFocus();
        btnLimparBusca.setVisibility(View.GONE);
    }

    /**
     * Mostra o estado de loading
     */
    private void mostrarLoading() {
        loadingState.setVisibility(View.VISIBLE);
        recyclerViewFuncionarios.setVisibility(View.GONE);
        emptyState.setVisibility(View.GONE);
    }

    /**
     * Esconde o estado de loading
     */
    private void esconderLoading() {
        loadingState.setVisibility(View.GONE);
        recyclerViewFuncionarios.setVisibility(View.VISIBLE);
    }

    /**
     * Mostra o empty state
     */
    private void mostrarEmptyState() {
        emptyState.setVisibility(View.VISIBLE);
        recyclerViewFuncionarios.setVisibility(View.GONE);
    }

    /**
     * Esconde o empty state
     */
    private void esconderEmptyState() {
        emptyState.setVisibility(View.GONE);
        recyclerViewFuncionarios.setVisibility(View.VISIBLE);
    }

    @Override
    public void onBackPressed() {
        if (modoSelecao) {
            // Cancelou seleção
            setResult(RESULT_CANCELED);
        }
        super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Limpa referências
        if (listaOriginal != null) {
            listaOriginal.clear();
        }
        if (listaFiltrada != null) {
            listaFiltrada.clear();
        }
    }
}
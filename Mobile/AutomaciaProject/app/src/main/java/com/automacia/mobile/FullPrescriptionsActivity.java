package com.automacia.mobile;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.adapters.CompletePrescriptionAdapter;
import com.automacia.mobile.models.PrescriptionDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.PrescriptionService;

import java.util.List;

public class FullPrescriptionsActivity extends AppCompatActivity {

    private static final String TAG = "FullPrescriptionsActivity";
    private static final String EXTRA_USUARIO = "usuario";

    // Views
    private ImageButton btnBack;
    private RecyclerView recyclerViewPrescriptions;
    private LinearLayout emptyStateLayout;
    private ProgressBar progressBar;

    // Data
    private CompletePrescriptionAdapter adapter;
    private PrescriptionService prescriptionService;
    private UsuarioDTO usuario;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_full_prescriptions);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Aplica animação de entrada
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_right);

        // Recupera o usuário da Intent
        usuario = (UsuarioDTO) getIntent().getSerializableExtra(EXTRA_USUARIO);

        if (usuario == null || usuario.getCpf() == null) {
            Log.e(TAG, "Usuário não foi passado corretamente para a Activity");
            Toast.makeText(this, "Erro: Dados do usuário não encontrados", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        Log.d(TAG, "Activity iniciada para CPF: " + usuario.getCpf());

        initViews();
        setupRecyclerView();
        setupListeners();
        loadPrescriptions();
    }

    /**
     * Inicializa as views
     */
    private void initViews() {
        btnBack = findViewById(R.id.btnBack);
        recyclerViewPrescriptions = findViewById(R.id.recyclerViewPrescriptions);
        emptyStateLayout = findViewById(R.id.emptyStateLayout);
        progressBar = findViewById(R.id.progressBar);
    }

    /**
     * Configura o RecyclerView e o Adapter
     */
    private void setupRecyclerView() {
        adapter = new CompletePrescriptionAdapter();

        recyclerViewPrescriptions.setLayoutManager(new LinearLayoutManager(this));
        recyclerViewPrescriptions.setAdapter(adapter);
        recyclerViewPrescriptions.setHasFixedSize(true);
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupListeners() {
        btnBack.setOnClickListener(v -> onBackPressed());
    }

    /**
     * Carrega as receitas do banco de dados
     */
    private void loadPrescriptions() {
        showLoading(true);

        prescriptionService = new PrescriptionService();

        prescriptionService.fetchCompletePrescriptions(usuario.getCpf(),
                new PrescriptionService.PrescriptionCallback() {
                    @Override
                    public void onSuccess(List<PrescriptionDTO> prescriptions) {
                        Log.d(TAG, "Receitas carregadas com sucesso: " + prescriptions.size());
                        showLoading(false);

                        if (prescriptions.isEmpty()) {
                            showEmptyState(true);
                        } else {
                            showEmptyState(false);
                            adapter.setPrescriptions(prescriptions);
                        }
                    }

                    @Override
                    public void onError(String errorMessage) {
                        Log.e(TAG, "Erro ao carregar receitas: " + errorMessage);
                        showLoading(false);
                        showEmptyState(true);
                        Toast.makeText(FullPrescriptionsActivity.this,
                                "Erro ao carregar receitas: " + errorMessage,
                                Toast.LENGTH_LONG).show();
                    }
                });
    }

    /**
     * Mostra ou esconde o loading
     */
    private void showLoading(boolean show) {
        progressBar.setVisibility(show ? View.VISIBLE : View.GONE);
        recyclerViewPrescriptions.setVisibility(show ? View.GONE : View.VISIBLE);
        emptyStateLayout.setVisibility(View.GONE);
    }

    /**
     * Mostra ou esconde o empty state
     */
    private void showEmptyState(boolean show) {
        emptyStateLayout.setVisibility(show ? View.VISIBLE : View.GONE);
        recyclerViewPrescriptions.setVisibility(show ? View.GONE : View.VISIBLE);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        // Aplica animação de saída
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_right);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Libera recursos do service
        if (prescriptionService != null) {
            prescriptionService.shutdown();
        }
    }
}
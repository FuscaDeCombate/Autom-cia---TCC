package com.automacia.mobile.quickactions;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.automacia.mobile.R;
import com.automacia.mobile.models.HistoricoMedicoDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.MedicalHistoryService;
import com.automacia.mobile.dialogs.PasswordConfirmationDialog;
import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.listener.OnLoadCompleteListener;
import com.github.barteksc.pdfviewer.listener.OnPageChangeListener;
import com.github.barteksc.pdfviewer.scroll.DefaultScrollHandle;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.card.MaterialCardView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class MedicalHistoryActivity extends AppCompatActivity {

    private static final String TAG = "MedicalHistoryActivity";
    private static final int REQUEST_PERMISSION_CODE = 100;

    // Views
    private ImageButton toolbar;
    private MaterialCardView emptyStateLayout;
    private LinearLayout pdfContainer;
    private MaterialButton btnAddPdf;
    private MaterialButton btnDownloadPdf;
    private MaterialButton btnSharePdf;
    private ImageButton btnDeletePdf;
    private PDFView pdfView;
    private ProgressBar progressBar;
    private TextView tvPdfName;
    private TextView tvPdfSize;
    private TextView tvCurrentPage;
    private TextView tvTotalPages;
    private LinearLayout pageInfoOverlay;

    private ScrollView emptyScrollView;

    // Dados
    private UsuarioDTO usuario;
    private HistoricoMedicoDTO historicoMedico;
    private MedicalHistoryService medicalHistoryService;

    // Launcher para seleção de arquivo
    private ActivityResultLauncher<Intent> pickPdfLauncher;
    private PasswordConfirmationDialog passwordDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_medical_history);

        Log.d(TAG, "==========================================");
        Log.d(TAG, "MedicalHistoryActivity iniciada");
        Log.d(TAG, "==========================================");

        // Aplica window insets
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Inicializa views
        initViews();

        // Recebe usuário via Intent
        receberUsuario();

        // Inicializa service
        medicalHistoryService = new MedicalHistoryService();

        // Configura launcher para seleção de PDF
        configurarPdfLauncher();

        // Configura listeners
        setupListeners();

        // Carrega histórico do banco
        carregarHistoricoMedico();
    }

    private void initViews() {
        Log.d(TAG, "Inicializando views");

        toolbar = findViewById(R.id.toolbar);
        emptyStateLayout = findViewById(R.id.emptyStateLayout);
        pdfContainer = findViewById(R.id.pdfContainer);
        btnAddPdf = findViewById(R.id.btnAddPdf);
        btnDownloadPdf = findViewById(R.id.btnDownloadPdf);
        btnSharePdf = findViewById(R.id.btnSharePdf);
        btnDeletePdf = findViewById(R.id.btnDeletePdf);
        pdfView = findViewById(R.id.pdfView);
        progressBar = findViewById(R.id.progressBar);
        tvPdfName = findViewById(R.id.tvPdfName);
        tvPdfSize = findViewById(R.id.tvPdfSize);
        tvCurrentPage = findViewById(R.id.tvCurrentPage);
        tvTotalPages = findViewById(R.id.tvTotalPages);
        pageInfoOverlay = findViewById(R.id.pageInfoOverlay);
        toolbar = findViewById(R.id.toolbar);
        emptyScrollView = findViewById(R.id.emptyScrollView);
    }

    private void receberUsuario() {
        Intent intent = getIntent();
        if (intent != null && intent.hasExtra("usuario")) {
            usuario = (UsuarioDTO) intent.getSerializableExtra("usuario");
            Log.d(TAG, "Usuário recebido: " + (usuario != null ? usuario.getNomeExibicao() : "null"));
            Log.d(TAG, "CPF: " + (usuario != null ? usuario.getCpf() : "null"));
        } else {
            Log.e(TAG, "Nenhum usuário foi passado via Intent!");
            Toast.makeText(this, "Erro: Usuário não identificado", Toast.LENGTH_SHORT).show();
            finish();
        }
    }

    private void configurarPdfLauncher() {
        pickPdfLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                        Uri pdfUri = result.getData().getData();
                        Log.d(TAG, "PDF selecionado: " + pdfUri);
                        processarPdfSelecionado(pdfUri);
                    }
                }
        );
    }

    private void setupListeners() {
        Log.d(TAG, "Configurando listeners");

        // Botão voltar
        toolbar.setOnClickListener(v -> {
            finish();
        });

        // Botão adicionar PDF
        btnAddPdf.setOnClickListener(v -> {
            Log.d(TAG, "Botão adicionar PDF pressionado");
            verificarPermissoesESelecionarPdf();
        });

        // Botão baixar PDF
        btnDownloadPdf.setOnClickListener(v -> {
            Log.d(TAG, "Botão baixar PDF pressionado");
            baixarPdf();
        });

        // Botão compartilhar PDF
        btnSharePdf.setOnClickListener(v -> {
            Log.d(TAG, "Botão compartilhar PDF pressionado");
            compartilharPdf();
        });

        // Botão deletar PDF
        btnDeletePdf.setOnClickListener(v -> {
            Log.d(TAG, "Botão deletar PDF pressionado");
            confirmarDelecao();
        });
    }

    private void carregarHistoricoMedico() {
        if (usuario == null) {
            Log.e(TAG, "Usuário é nulo, não é possível carregar histórico");
            return;
        }

        Log.d(TAG, "Carregando histórico médico do banco de dados");
        showProgress(true);

        // Executa em thread separada
        new Thread(() -> {
            historicoMedico = medicalHistoryService.buscarHistoricoPorCPF(usuario.getCpf());

            // Atualiza UI na thread principal
            runOnUiThread(() -> {
                showProgress(false);

                if (historicoMedico != null) {
                    Log.d(TAG, "Histórico médico encontrado!");
                    exibirPdf(historicoMedico);
                } else {
                    Log.d(TAG, "Nenhum histórico médico encontrado");
                    exibirEstadoVazio();
                }
            });
        }).start();
    }

    private void exibirEstadoVazio() {
        Log.d(TAG, "Exibindo estado vazio");
        emptyScrollView.setVisibility(View.VISIBLE);
        pdfContainer.setVisibility(View.GONE);
    }

    private void exibirPdf(HistoricoMedicoDTO historico) {
        Log.d(TAG, "Exibindo PDF");
        Log.d(TAG, "Nome: " + historico.getNomeArquivo());
        Log.d(TAG, "Tamanho: " + historico.getTamanhoFormatado());

        emptyScrollView.setVisibility(View.GONE);
        pdfContainer.setVisibility(View.VISIBLE);

        // Atualiza informações do PDF
        tvPdfName.setText(historico.getNomeArquivo());
        tvPdfSize.setText(historico.getTamanhoFormatado());

        // Carrega o PDF
        carregarPdfNoViewer(historico.getRegistroMedico());
    }

    private void carregarPdfNoViewer(byte[] pdfBytes) {
        Log.d(TAG, "Carregando PDF no viewer");
        progressBar.setVisibility(View.VISIBLE);

        pdfView.fromBytes(pdfBytes)
                .defaultPage(0)
                .enableSwipe(true)
                .swipeHorizontal(false)
                .enableDoubletap(true)
                .scrollHandle(new DefaultScrollHandle(this))
                .spacing(10)
                .onLoad(new OnLoadCompleteListener() {
                    @Override
                    public void loadComplete(int nbPages) {
                        progressBar.setVisibility(View.GONE);
                        pageInfoOverlay.setVisibility(View.VISIBLE);
                        tvTotalPages.setText(String.valueOf(nbPages));
                        tvCurrentPage.setText("1");
                        Log.d(TAG, "PDF carregado com sucesso. Total de páginas: " + nbPages);
                    }
                })
                .onPageChange(new OnPageChangeListener() {
                    @Override
                    public void onPageChanged(int page, int pageCount) {
                        tvCurrentPage.setText(String.valueOf(page + 1));
                        Log.d(TAG, "Página alterada: " + (page + 1) + "/" + pageCount);
                    }
                })
                .onError(t -> {
                    progressBar.setVisibility(View.GONE);
                    Log.e(TAG, "Erro ao carregar PDF", t);
                    Toast.makeText(MedicalHistoryActivity.this,
                            "Erro ao carregar PDF: " + t.getMessage(),
                            Toast.LENGTH_SHORT).show();
                })
                .load();
    }

    private void verificarPermissoesESelecionarPdf() {
        Log.d(TAG, "Verificando permissões de armazenamento");

        // Android 10+ (não precisa de permissão especial para ACTION_OPEN_DOCUMENT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            selecionarPdf();
            return;
        }

        // Android 9 ou inferior
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED) {
            selecionarPdf();
        } else {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                    REQUEST_PERMISSION_CODE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if (requestCode == REQUEST_PERMISSION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Permissão concedida pelo usuário");
                selecionarPdf();
            } else {
                Log.w(TAG, "Permissão negada pelo usuário");
                Toast.makeText(this, "Permissão necessária para selecionar arquivo",
                        Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void selecionarPdf() {
        Log.d(TAG, "Abrindo seletor de arquivos PDF");
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("application/pdf");
        pickPdfLauncher.launch(intent);
    }

    private void processarPdfSelecionado(Uri pdfUri) {
        Log.d(TAG, "Processando PDF selecionado");

        // Primeiro lê o PDF
        new Thread(() -> {
            try {
                InputStream inputStream = getContentResolver().openInputStream(pdfUri);
                byte[] pdfBytes = inputStreamToByteArray(inputStream);
                inputStream.close();

                Log.d(TAG, "PDF lido com sucesso. Tamanho: " + pdfBytes.length + " bytes");

                // Solicita senha na UI thread
                runOnUiThread(() -> mostrarDialogSenha(pdfBytes));

            } catch (Exception e) {
                Log.e(TAG, "Erro ao ler PDF", e);
                runOnUiThread(() -> {
                    Toast.makeText(this, "Erro ao ler PDF: " + e.getMessage(),
                            Toast.LENGTH_SHORT).show();
                });
            }
        }).start();
    }

    private void mostrarDialogSenha(byte[] pdfBytes) {
        Log.d(TAG, "Mostrando dialog de senha");

        passwordDialog = PasswordConfirmationDialog.newInstance(senha -> {
            Log.d(TAG, "Senha informada, iniciando upload");
            enviarPdfParaBanco(pdfBytes, senha);
        });

        passwordDialog.show(getSupportFragmentManager(), "PasswordConfirmationDialog");
    }

    private void enviarPdfParaBanco(byte[] pdfBytes, String senha) {
        showProgress(true);

        new Thread(() -> {
            boolean sucesso = medicalHistoryService.inserirHistorico(
                    usuario.getCpf(),
                    senha,
                    pdfBytes
            );

            runOnUiThread(() -> {
                showProgress(false);

                if (sucesso) {
                    // Fecha o dialog e mostra sucesso
                    if (passwordDialog != null) {
                        passwordDialog.closeDialog();
                    }
                    Toast.makeText(this, "Histórico médico adicionado com sucesso!",
                            Toast.LENGTH_SHORT).show();
                    carregarHistoricoMedico();
                } else {
                    // Reseta o botão e mostra erro
                    if (passwordDialog != null) {
                        passwordDialog.resetButton();
                        passwordDialog.showError("Senha incorreta. Tente novamente.");
                    }
                    Toast.makeText(this, "Senha incorreta. Verifique e tente novamente.",
                            Toast.LENGTH_LONG).show();
                }
            });

        }).start();
    }

    private byte[] inputStreamToByteArray(InputStream inputStream) throws IOException {
        byte[] buffer = new byte[8192];
        int bytesRead;
        java.io.ByteArrayOutputStream output = new java.io.ByteArrayOutputStream();
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            output.write(buffer, 0, bytesRead);
        }
        return output.toByteArray();
    }

    private void baixarPdf() {
        if (historicoMedico == null) {
            Toast.makeText(this, "Nenhum PDF para baixar", Toast.LENGTH_SHORT).show();
            return;
        }

        Log.d(TAG, "Baixando PDF para Downloads");
        showProgress(true);

        new Thread(() -> {
            try {
                File downloadsDir = Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_DOWNLOADS);
                File pdfFile = new File(downloadsDir, historicoMedico.getNomeArquivo());

                // Escreve o PDF no arquivo
                FileOutputStream fos = new FileOutputStream(pdfFile);
                fos.write(historicoMedico.getRegistroMedico());
                fos.close();

                Log.d(TAG, "PDF salvo em: " + pdfFile.getAbsolutePath());

                runOnUiThread(() -> {
                    showProgress(false);
                    Toast.makeText(this, "PDF baixado para: Downloads/" +
                            historicoMedico.getNomeArquivo(), Toast.LENGTH_LONG).show();
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro ao baixar PDF", e);
                runOnUiThread(() -> {
                    showProgress(false);
                    Toast.makeText(this, "Erro ao baixar PDF: " + e.getMessage(),
                            Toast.LENGTH_SHORT).show();
                });
            }
        }).start();
    }

    private void compartilharPdf() {
        if (historicoMedico == null) {
            Toast.makeText(this, "Nenhum PDF para compartilhar", Toast.LENGTH_SHORT).show();
            return;
        }

        Log.d(TAG, "Compartilhando PDF");
        showProgress(true);

        new Thread(() -> {
            try {
                // Salva temporariamente no cache
                File cacheDir = getCacheDir();
                File pdfFile = new File(cacheDir, historicoMedico.getNomeArquivo());

                FileOutputStream fos = new FileOutputStream(pdfFile);
                fos.write(historicoMedico.getRegistroMedico());
                fos.close();

                Log.d(TAG, "PDF temporário criado em: " + pdfFile.getAbsolutePath());

                // Cria URI usando FileProvider
                Uri pdfUri = FileProvider.getUriForFile(
                        this,
                        getPackageName() + ".fileprovider",
                        pdfFile
                );

                runOnUiThread(() -> {
                    showProgress(false);

                    Intent shareIntent = new Intent(Intent.ACTION_SEND);
                    shareIntent.setType("application/pdf");
                    shareIntent.putExtra(Intent.EXTRA_STREAM, pdfUri);
                    shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    shareIntent.putExtra(Intent.EXTRA_SUBJECT, "Histórico Médico");
                    shareIntent.putExtra(Intent.EXTRA_TEXT, "Compartilhando histórico médico");

                    startActivity(Intent.createChooser(shareIntent, "Compartilhar PDF"));
                    Log.d(TAG, "Intent de compartilhamento iniciado");
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro ao compartilhar PDF", e);
                runOnUiThread(() -> {
                    showProgress(false);
                    Toast.makeText(this, "Erro ao compartilhar PDF: " + e.getMessage(),
                            Toast.LENGTH_SHORT).show();
                });
            }
        }).start();
    }

    private void confirmarDelecao() {
        Log.d(TAG, "Solicitando confirmação de deleção");

        Drawable icon = ContextCompat.getDrawable(this, R.drawable.ic_warning);
        if (icon != null) {
            icon.setTint(ContextCompat.getColor(this, R.color.red)); // ou qualquer cor do tema
        }

        new com.google.android.material.dialog.MaterialAlertDialogBuilder(this)
                .setTitle("Excluir Histórico Médico")
                .setMessage("Tem certeza que deseja excluir seu histórico médico? Esta ação não pode ser desfeita.")
                .setPositiveButton("Excluir", (dialog, which) -> {
                    Log.d(TAG, "Deleção confirmada pelo usuário");
                    deletarPdf();
                })
                .setNegativeButton("Cancelar", (dialog, which) -> {
                    Log.d(TAG, "Deleção cancelada pelo usuário");
                    dialog.dismiss();
                })
                .setIcon(icon)
                .show();
    }

    private void deletarPdf() {
        if (historicoMedico == null) {
            Toast.makeText(this, "Nenhum PDF para deletar", Toast.LENGTH_SHORT).show();
            return;
        }

        Log.d(TAG, "Deletando histórico médico");
        Log.d(TAG, "ID: " + historicoMedico.getIdHistorico());

        // TODO: Implementar procedure de deleção no banco
        // Por enquanto, apenas limpa a visualização

        Toast.makeText(this, "Função de deletar será implementada em breve",
                Toast.LENGTH_SHORT).show();

        // Simulação de deleção
        // historicoMedico = null;
        // exibirEstadoVazio();
    }

    private void showProgress(boolean show) {
        runOnUiThread(() -> {
            progressBar.setVisibility(show ? View.VISIBLE : View.GONE);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
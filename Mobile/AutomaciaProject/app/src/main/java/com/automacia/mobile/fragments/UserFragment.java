package com.automacia.mobile.fragments;

import static com.automacia.mobile.R.drawable.btn_gradient_danger;
import static com.automacia.mobile.R.drawable.btn_gradient_primary;

import android.animation.ValueAnimator;
import android.app.AlertDialog;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.fragment.app.Fragment;

import com.automacia.mobile.MyApp;
import com.automacia.mobile.R;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.PerfilService;
import com.automacia.mobile.utils.PasswordConfirmationDialog;
import com.automacia.mobile.utils.Utils;
import com.automacia.mobile.watchers.TelefoneMaskWatcher;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserFragment extends Fragment {

    private static final String TAG = "UserFragment";
    private static final String ARG_USUARIO = "usuario";
    private static final int ANIMATION_DURATION = 300;

    // Views
    private CircleImageView icProfilePhoto;
    private TextView tvChangePhoto;
    private TextInputLayout layoutNomeCon, layoutCpf, layoutEmail, layoutTel, layoutNomeSoc;
    private TextInputEditText etNome, etCpf, etEmail, etTelefone, etNomeSocial;
    private MaterialButton btnEditar, btnSalvar;
    private View viewSpacing;
    private LinearLayout llButtonsContainer;

    // Estado
    private boolean isEditing = false;
    private UsuarioDTO usuario;

    // Flags de validação
    private boolean isNomeValido = true;
    private boolean isEmailValido = true;
    private boolean isTelefoneValido = true;
    private boolean isNomeSocialValido = true;

    // Dados originais para cancelamento
    private String nomeOriginal;
    private String emailOriginal;
    private String telefoneOriginal;
    private String nomeSocialOriginal;

    // Executor para operações em background
    private final ExecutorService executorService = Executors.newSingleThreadExecutor();

    public UserFragment() {
        // Required empty public constructor
    }

    public static UserFragment newInstance(UsuarioDTO usuario) {
        UserFragment fragment = new UserFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_USUARIO, usuario);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            usuario = (UsuarioDTO) getArguments().getSerializable(ARG_USUARIO);
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_user, container, false);

        initViews(view);

        if (areViewsInitialized()) {
            setupClickListeners();
            loadUserData();
        } else {
            Log.e(TAG, "Views não foram inicializadas corretamente");
            Toast.makeText(getContext(), "Erro ao carregar tela", Toast.LENGTH_SHORT).show();
        }

        return view;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // Shutdown do executor para evitar memory leaks
        if (executorService != null && !executorService.isShutdown()) {
            executorService.shutdown();
        }
    }

    private void initViews(View view) {
        icProfilePhoto = view.findViewById(R.id.iv_profile_photo);
        tvChangePhoto = view.findViewById(R.id.tv_change_photo);
        etNome = view.findViewById(R.id.et_nome);
        etCpf = view.findViewById(R.id.et_cpf);
        etEmail = view.findViewById(R.id.et_email);
        etTelefone = view.findViewById(R.id.et_telefone);
        etNomeSocial = view.findViewById(R.id.et_nome_social);
        btnEditar = view.findViewById(R.id.btn_editar);
        btnSalvar = view.findViewById(R.id.btn_salvar);
        viewSpacing = view.findViewById(R.id.view_spacing);
        llButtonsContainer = view.findViewById(R.id.ll_buttons_container);
        layoutNomeCon = view.findViewById(R.id.lay_nome_com);
        layoutCpf = view.findViewById(R.id.lay_cpf);
        layoutTel = view.findViewById(R.id.lay_telefone);
        layoutEmail = view.findViewById(R.id.lay_email);
        layoutNomeSoc = view.findViewById(R.id.lay_nome_soc);
    }

    private boolean areViewsInitialized() {
        return etNome != null && etCpf != null && etEmail != null &&
                etTelefone != null && etNomeSocial != null &&
                btnEditar != null && btnSalvar != null &&
                layoutNomeCon != null && layoutEmail != null && layoutTel != null;
    }

    private void setupClickListeners() {

        if (tvChangePhoto != null) {
            tvChangePhoto.setOnClickListener(v -> {
                // TODO: Implementar seleção de foto
                Toast.makeText(getContext(), "Funcionalidade em desenvolvimento", Toast.LENGTH_SHORT).show();
            });
        }

        if (btnEditar != null) {
            btnEditar.setOnClickListener(v -> {
                if (isEditing) {
                    cancelEdit();
                } else {
                    toggleEditMode();
                }
            });
        }

        if (btnSalvar != null) {
            btnSalvar.setOnClickListener(v -> showPasswordDialog());
        }
    }

    /**
     * Exibe um AlertDialog para solicitar a senha do usuário
     */
    private void showPasswordDialog() {
        if (getActivity() == null) return;

        PasswordConfirmationDialog dialog = PasswordConfirmationDialog.newInstance(password -> {
            saveUserDataWithPassword(password);
        });

        dialog.show(getParentFragmentManager(), "PasswordConfirmationDialog");
    }

    private void saveUserDataWithPassword(String senha) {
        // Buscar o dialog do FragmentManager
        PasswordConfirmationDialog dialog = (PasswordConfirmationDialog)
                getParentFragmentManager().findFragmentByTag("PasswordConfirmationDialog");

        if (dialog == null) {
            Log.e(TAG, "Dialog não encontrado");
            return;
        }

        saveUserData(senha, dialog);
    }

    /**
     * Salva os dados do usuário no banco de dados
     * Executa a operação em uma thread separada para não bloquear a UI
     */
    private void saveUserData(String senha, PasswordConfirmationDialog dialog) {
        if (!areViewsInitialized() || usuario == null) {
            Log.e(TAG, "Tentativa de salvar dados com views não inicializadas ou usuário nulo");
            return;
        }

        // Validar todos os campos antes de salvar
        if (!validateAllFields()) {
            Toast.makeText(getContext(), "Por favor, corrija os erros antes de salvar", Toast.LENGTH_SHORT).show();
            dialog.resetButton();
            return;
        }

        // Desabilitar botão salvar também
        if (btnSalvar != null) {
            btnSalvar.setEnabled(false);
            btnSalvar.setText("Salvando...");
        }

        // Coletar dados normalizados
        final String nome = Utils.normalizarNome(etNome.getText().toString());
        final String email = Utils.normalizarEmail(etEmail.getText().toString());
        final String telefone = Utils.extrairNumeros(etTelefone.getText().toString());
        final String nomeSocial = etNomeSocial.getText() != null && !etNomeSocial.getText().toString().trim().isEmpty()
                ? Utils.normalizarNome(etNomeSocial.getText().toString())
                : "";

        // Criar DTO temporário com os novos dados
        final UsuarioDTO usuarioAtualizado = new UsuarioDTO(
                usuario.getCpf(),
                nome,
                nomeSocial.isEmpty() ? null : nomeSocial,
                email,
                telefone
        );

        // Executar salvamento em thread separada
        executorService.execute(() -> {
            try {
                Log.d(TAG, "Iniciando salvamento de dados do usuário");

                // Chamar o serviço de atualização
                PerfilService.ResultadoAtualizacao resultado =
                        PerfilService.atualizarPerfil(usuarioAtualizado, senha);

                // Voltar para a UI thread para atualizar a interface
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        handleSaveResult(resultado, usuarioAtualizado, dialog);
                    });
                }

            } catch (Exception e) {
                Log.e(TAG, "Erro inesperado ao salvar dados", e);

                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        Toast.makeText(getContext(), "Erro inesperado ao salvar dados", Toast.LENGTH_LONG).show();
                        dialog.resetButton();

                        if (btnSalvar != null) {
                            btnSalvar.setText("Salvar");
                            btnSalvar.setEnabled(true);
                        }
                    });
                }
            }
        });
    }

    /**
     * Processa o resultado da operação de salvamento
     */
    private void handleSaveResult(PerfilService.ResultadoAtualizacao resultado,
                                  UsuarioDTO usuarioAtualizado,
                                  PasswordConfirmationDialog dialog) {
        if (resultado.isSucesso()) {
            Log.i(TAG, "Dados salvos com sucesso");

            // Atualizar o objeto usuario local
            usuario.setNome(usuarioAtualizado.getNome());
            usuario.setEmail(usuarioAtualizado.getEmail());
            usuario.setTelefone(usuarioAtualizado.getTelefone());
            usuario.setNomeSocial(usuarioAtualizado.getNomeSocial());

            // Atualizar o usuário logado no MyApp
            if (getActivity() != null && getActivity().getApplication() instanceof MyApp) {
                MyApp app = (MyApp) getActivity().getApplication();
                app.setUsuarioLogado(usuario);
                Log.d(TAG, "Usuário atualizado no MyApp");
            }

            // Atualizar dados originais
            saveOriginalData();
            Toast.makeText(getContext(), resultado.getMensagem(), Toast.LENGTH_SHORT).show();

            if (dialog != null) {
                dialog.dismiss();
            }

            exitEditMode();

        } else {
            Log.w(TAG, "Falha ao salvar dados: " + resultado.getMensagem());
            Toast.makeText(getContext(), resultado.getMensagem(), Toast.LENGTH_LONG).show();

            dialog.resetButton();

            if (btnSalvar != null) {
                btnSalvar.setText("Salvar");
                btnSalvar.setEnabled(true);
            }
        }
    }

    /**
     * Configura os validadores em tempo real para os campos editáveis
     */
    private void setupValidators() {
        setupNomeValidator();
        setupEmailValidator();
        setupTelefoneValidator();
        setupNomeSocialValidator();
    }

    private void setupNomeValidator() {
        etNome.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarNome(s.toString());
                layoutNomeCon.setError(erro);
                isNomeValido = (erro == null);
                updateSaveButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void setupEmailValidator() {
        etEmail.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarEmail(s.toString());
                layoutEmail.setError(erro);
                isEmailValido = (erro == null);
                updateSaveButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void setupTelefoneValidator() {
        // Aplica máscara de telefone
        etTelefone.addTextChangedListener(new TelefoneMaskWatcher(etTelefone));

        etTelefone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarTelefone(s.toString());
                layoutTel.setError(erro);

                String telefoneNumeros = Utils.extrairNumeros(s.toString());
                isTelefoneValido = (erro == null && telefoneNumeros.length() >= 10 && telefoneNumeros.length() <= 11);
                updateSaveButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void setupNomeSocialValidator() {
        etNomeSocial.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String texto = s.toString().trim();
                if (!texto.isEmpty()) {
                    String erro = Utils.validarNome(texto);
                    layoutNomeSoc.setError(erro);
                    isNomeSocialValido = (erro == null);
                } else {
                    layoutNomeSoc.setError(null);
                    isNomeSocialValido = true;
                }
                updateSaveButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Atualiza o estado do botão salvar baseado nas validações
     */
    private void updateSaveButtonState() {
        if (!isEditing || btnSalvar == null) return;

        boolean todosValidos = isNomeValido && isEmailValido && isTelefoneValido && isNomeSocialValido;

        btnSalvar.setEnabled(todosValidos);
        btnSalvar.setAlpha(todosValidos ? 1.0f : 0.5f);
    }

    private void loadUserData() {
        if (!areViewsInitialized()) {
            Log.e(TAG, "Tentativa de carregar dados com views não inicializadas");
            return;
        }

        try {
            if (usuario != null) {
                // Carregar dados do DTO recebido
                etNome.setText(usuario.getNome());
                etCpf.setText(Utils.formatCpf(usuario.getCpf()));
                etEmail.setText(usuario.getEmail());
                etTelefone.setText(usuario.getTelefone());
                etNomeSocial.setText(usuario.getNomeSocial() != null ? usuario.getNomeSocial() : "");

                // Salvar dados originais
                saveOriginalData();
            } else {
                Log.w(TAG, "UsuarioDTO não foi fornecido ao fragment");
                Toast.makeText(getContext(), "Erro ao carregar dados do usuário", Toast.LENGTH_SHORT).show();
            }

            // Após carregar os dados, define todos como válidos
            isNomeValido = true;
            isEmailValido = true;
            isTelefoneValido = true;
            isNomeSocialValido = true;
        } catch (Exception e) {
            Log.e(TAG, "Erro ao carregar dados do usuário", e);
            Toast.makeText(getContext(), "Erro ao carregar dados", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * Salva os dados originais para poder restaurar em caso de cancelamento
     */
    private void saveOriginalData() {
        nomeOriginal = etNome.getText() != null ? etNome.getText().toString() : "";
        emailOriginal = etEmail.getText() != null ? etEmail.getText().toString() : "";
        telefoneOriginal = etTelefone.getText() != null ? etTelefone.getText().toString() : "";
        nomeSocialOriginal = etNomeSocial.getText() != null ? etNomeSocial.getText().toString() : "";
    }

    /**
     * Restaura os dados originais nos campos
     */
    private void restoreOriginalData() {
        if (etNome != null) etNome.setText(nomeOriginal);
        if (etEmail != null) etEmail.setText(emailOriginal);
        if (etTelefone != null) etTelefone.setText(telefoneOriginal);
        if (etNomeSocial != null) etNomeSocial.setText(nomeSocialOriginal);
    }

    private void toggleEditMode() {
        if (!areViewsInitialized()) {
            Log.e(TAG, "Tentativa de alternar modo de edição com views não inicializadas");
            return;
        }

        if (isEditing) {
            cancelEdit();
        } else {
            isEditing = true;

            try {
                // Alterar estados dos campos
                etNome.setEnabled(true);
                etEmail.setEnabled(true);
                etTelefone.setEnabled(true);
                etNomeSocial.setEnabled(true);
                etCpf.setEnabled(false); // CPF sempre desabilitado

                // Configurar validadores
                setupValidators();

                // Animar para modo de edição
                animateToEditMode();

                updateSaveButtonState();
            } catch (Exception e) {
                Log.e(TAG, "Erro ao entrar no modo de edição", e);
            }
        }
    }

    private void animateToEditMode() {
        if (btnSalvar == null || btnEditar == null || viewSpacing == null) return;

        btnSalvar.setVisibility(View.VISIBLE);
        btnSalvar.setAlpha(0f);

        LinearLayout.LayoutParams editarParams = (LinearLayout.LayoutParams) btnEditar.getLayoutParams();
        LinearLayout.LayoutParams salvarParams = (LinearLayout.LayoutParams) btnSalvar.getLayoutParams();
        LinearLayout.LayoutParams spacingParams = (LinearLayout.LayoutParams) viewSpacing.getLayoutParams();

        ValueAnimator animator = ValueAnimator.ofFloat(0f, 1f);
        animator.setDuration(ANIMATION_DURATION);
        animator.setInterpolator(new AccelerateDecelerateInterpolator());

        animator.addUpdateListener(animation -> {
            float progress = animation.getAnimatedFraction();

            editarParams.weight = 1f - (progress * 0.52f);
            salvarParams.weight = progress * 0.48f;
            spacingParams.weight = progress * 0.04f;
            btnSalvar.setAlpha(progress);

            btnEditar.setLayoutParams(editarParams);
            btnSalvar.setLayoutParams(salvarParams);
            viewSpacing.setLayoutParams(spacingParams);

            if (progress > 0f && viewSpacing.getVisibility() != View.VISIBLE) {
                viewSpacing.setVisibility(View.VISIBLE);
            }
        });

        animateButtonBackgroundTextAndIcon(btnEditar, "Cancelar", btn_gradient_danger, R.drawable.ic_close);
        animator.start();
    }

    private void animateToViewMode() {
        if (btnSalvar == null || btnEditar == null || viewSpacing == null) return;

        LinearLayout.LayoutParams editarParams = (LinearLayout.LayoutParams) btnEditar.getLayoutParams();
        LinearLayout.LayoutParams salvarParams = (LinearLayout.LayoutParams) btnSalvar.getLayoutParams();
        LinearLayout.LayoutParams spacingParams = (LinearLayout.LayoutParams) viewSpacing.getLayoutParams();

        ValueAnimator animator = ValueAnimator.ofFloat(1f, 0f);
        animator.setDuration(ANIMATION_DURATION);
        animator.setInterpolator(new AccelerateDecelerateInterpolator());

        animator.addUpdateListener(animation -> {
            float progress = animation.getAnimatedFraction();

            editarParams.weight = 0.48f + (progress * 0.52f);
            salvarParams.weight = 0.48f - (progress * 0.48f);
            spacingParams.weight = 0.04f - (progress * 0.04f);
            btnSalvar.setAlpha(1f - progress);

            btnEditar.setLayoutParams(editarParams);
            btnSalvar.setLayoutParams(salvarParams);
            viewSpacing.setLayoutParams(spacingParams);
        });

        animator.addListener(new android.animation.AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(android.animation.Animator animation) {
                btnSalvar.setVisibility(View.GONE);
                viewSpacing.setVisibility(View.GONE);
            }
        });

        animateButtonBackgroundTextAndIcon(btnEditar, "Editar", btn_gradient_primary, R.drawable.ic_edit);
        animator.start();
    }

    /**
     * Anima a mudança de background, texto e ícone do MaterialButton
     */
    private void animateButtonBackgroundTextAndIcon(MaterialButton button, String newText, int newBackgroundRes, int newIconRes) {
        if (button == null || getContext() == null) return;

        final var newDrawable = AppCompatResources.getDrawable(getContext(), newBackgroundRes);
        final var newIcon = AppCompatResources.getDrawable(getContext(), newIconRes);

        ValueAnimator backgroundTransition = ValueAnimator.ofFloat(1f, 0f);
        backgroundTransition.setDuration(ANIMATION_DURATION);
        backgroundTransition.setInterpolator(new AccelerateDecelerateInterpolator());

        backgroundTransition.addUpdateListener(animation -> {
            float progress = animation.getAnimatedFraction();

            if (progress <= 0.5f) {
                int alpha = (int) (255 * (1f - progress * 2f));
                if (button.getBackground() != null) {
                    button.getBackground().setAlpha(Math.max(alpha, 50));
                }
            } else {
                if (progress >= 0.5f && !button.getText().toString().equals(newText)) {
                    button.setText(newText);
                    button.setBackground(newDrawable);
                    button.setIcon(newIcon);
                }
                int alpha = (int) (255 * ((progress - 0.5f) * 2f));
                if (button.getBackground() != null) {
                    button.getBackground().setAlpha(Math.min(alpha, 255));
                }
            }
        });

        backgroundTransition.addListener(new android.animation.AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(android.animation.Animator animation) {
                if (button.getBackground() != null) {
                    button.getBackground().setAlpha(255);
                }
            }
        });

        backgroundTransition.start();
    }

    private void cancelEdit() {
        clearAllErrors();
        restoreOriginalData();
        exitEditMode();
    }

    /**
     * Limpa todos os erros de validação
     */
    private void clearAllErrors() {
        if (layoutNomeCon != null) layoutNomeCon.setError(null);
        if (layoutEmail != null) layoutEmail.setError(null);
        if (layoutTel != null) layoutTel.setError(null);
        if (layoutNomeSoc != null) layoutNomeSoc.setError(null);
    }

    /**
     * Validação final de todos os campos editáveis antes de salvar
     */
    private boolean validateAllFields() {
        boolean isValid = true;

        // Validar nome
        String erroNome = Utils.validarNome(etNome.getText().toString());
        layoutNomeCon.setError(erroNome);
        if (erroNome != null) isValid = false;

        // Validar email
        String erroEmail = Utils.validarEmail(etEmail.getText().toString());
        layoutEmail.setError(erroEmail);
        if (erroEmail != null) isValid = false;

        // Validar telefone
        String erroTelefone = Utils.validarTelefone(etTelefone.getText().toString());
        layoutTel.setError(erroTelefone);
        if (erroTelefone != null) isValid = false;

        // Verificar se telefone tem quantidade correta de dígitos
        String telefoneNumeros = Utils.extrairNumeros(etTelefone.getText().toString());
        if (telefoneNumeros.length() < 10 || telefoneNumeros.length() > 11) {
            layoutTel.setError("Telefone deve ter entre 10 e 11 dígitos");
            isValid = false;
        }

        // Validar nome social (se não estiver vazio)
        String nomeSocial = etNomeSocial.getText().toString().trim();
        if (!nomeSocial.isEmpty()) {
            String erroNomeSocial = Utils.validarNome(nomeSocial);
            layoutNomeSoc.setError(erroNomeSocial);
            if (erroNomeSocial != null) isValid = false;
        }

        return isValid;
    }

    /**
     * Sai do modo de edição e volta ao modo de visualização
     */
    private void exitEditMode() {
        if (!isEditing) return;

        if (!areViewsInitialized()) {
            Log.e(TAG, "Tentativa de sair do modo de edição com views não inicializadas");
            return;
        }

        isEditing = false;

        try {
            // Desabilitar campos
            etNome.setEnabled(false);
            etEmail.setEnabled(false);
            etTelefone.setEnabled(false);
            etNomeSocial.setEnabled(false);
            etCpf.setEnabled(false);

            // Limpar erros
            clearAllErrors();

            // Animar volta ao modo view
            animateToViewMode();

            // Resetar flags de validação
            isNomeValido = true;
            isEmailValido = true;
            isTelefoneValido = true;
            isNomeSocialValido = true;
        } catch (Exception e) {
            Log.e(TAG, "Erro ao sair do modo de edição", e);
        }
    }
}
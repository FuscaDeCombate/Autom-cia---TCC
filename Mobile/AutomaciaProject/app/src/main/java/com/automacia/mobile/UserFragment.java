package com.automacia.mobile;

import static com.automacia.mobile.R.drawable.btn_gradient_danger;
import static com.automacia.mobile.R.drawable.btn_gradient_primary;

import android.animation.ValueAnimator;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.animation.AccelerateDecelerateInterpolator;

import androidx.appcompat.content.res.AppCompatResources;
import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import com.google.android.material.button.MaterialButton;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserFragment extends Fragment {

    // Views
    private ImageButton btnBack;
    private CircleImageView icProfilePhoto;
    private TextView tvChangePhoto;
    private TextInputLayout layoutNomeCon, layoutCpf, layoutEmail, layoutTel, layoutNomeSoc;
    private TextInputEditText etNome, etCpf, etEmail, etTelefone, etNomeSocial;
    private MaterialButton btnEditar, btnSalvar;
    private View viewSpacing;
    private LinearLayout llButtonsContainer;

    private boolean isEditing = false;
    private static final int ANIMATION_DURATION = 300;

    // Flags de validação
    private boolean isNomeValido = true; // Inicia como true pois já tem dados válidos
    private boolean isEmailValido = true;
    private boolean isTelefoneValido = true;
    private boolean isNomeSocialValido = true; // Nome social é opcional, então sempre válido

    public UserFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_user, container, false);

        initViews(view);

        // Só chama os métodos depois que as views estão inicializadas
        if (areViewsInitialized()) {
            setupClickListeners();
            loadUserData();
        } else {
            // Log para debug
            android.util.Log.e("UserFragment", "Views não foram inicializadas corretamente");
        }

        return view;
    }

    private void initViews(View view) {
        btnBack = view.findViewById(R.id.btn_back);
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

        // Log para debug - verificar quais views estão null
        logNullViews();
    }

    private void logNullViews() {
        android.util.Log.d("UserFragment", "=== Verificação de Views ===");
        if (etNome == null) android.util.Log.e("UserFragment", "etNome é null");
        if (etCpf == null) android.util.Log.e("UserFragment", "etCpf é null");
        if (etEmail == null) android.util.Log.e("UserFragment", "etEmail é null");
        if (etTelefone == null) android.util.Log.e("UserFragment", "etTelefone é null");
        if (etNomeSocial == null) android.util.Log.e("UserFragment", "etNomeSocial é null");
        if (btnEditar == null) android.util.Log.e("UserFragment", "btnEditar é null");
        if (btnSalvar == null) android.util.Log.e("UserFragment", "btnSalvar é null");
    }

    private boolean areViewsInitialized() {
        return etNome != null && etCpf != null && etEmail != null &&
                etTelefone != null && etNomeSocial != null &&
                btnEditar != null && btnSalvar != null;
    }

    private void setupClickListeners() {
        if (btnBack != null) {
            btnBack.setOnClickListener(v -> {
                if (getActivity() != null) {
                    getActivity().getOnBackPressedDispatcher().onBackPressed();
                }
            });
        }

        if (tvChangePhoto != null) {
            tvChangePhoto.setOnClickListener(v -> {
                // TODO: Implementar seleção de foto
                Toast.makeText(getContext(), "Selecionar foto", Toast.LENGTH_SHORT).show();
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
            btnSalvar.setOnClickListener(v -> saveUserData());
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

    /**
     * Validador para o campo Nome
     */
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

    /**
     * Validador para o campo Email
     */
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

    /**
     * Validador para o campo Telefone com máscara
     */
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

    /**
     * Validador para o campo Nome Social (opcional)
     */
    private void setupNomeSocialValidator() {
        etNomeSocial.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                // Nome social é opcional, só valida se não estiver vazio
                String texto = s.toString().trim();
                if (!texto.isEmpty()) {
                    String erro = Utils.validarNome(texto);
                    layoutNomeSoc.setError(erro);
                    isNomeSocialValido = (erro == null);
                } else {
                    layoutNomeSoc.setError(null);
                    isNomeSocialValido = true; // Vazio é válido para nome social
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
        // Verificar se as views estão inicializadas antes de usá-las
        if (!areViewsInitialized()) {
            android.util.Log.e("UserFragment", "Tentativa de carregar dados com views não inicializadas");
            return;
        }

        //TODO: carregamento de dados reais do Banco
        // Simulação
        try {
            etNome.setText("João Silva");
            etCpf.setText("123.456.789-00");
            etEmail.setText("joao@email.com");
            etTelefone.setText("(11) 99999-9999");
            etNomeSocial.setText("");

            // Após carregar os dados, define todos como válidos
            isNomeValido = true;
            isEmailValido = true;
            isTelefoneValido = true;
            isNomeSocialValido = true;
        } catch (Exception e) {
            android.util.Log.e("UserFragment", "Erro ao carregar dados do usuário: " + e.getMessage());
        }
    }

    private void toggleEditMode() {
        if (!areViewsInitialized()) {
            android.util.Log.e("UserFragment", "Tentativa de alternar modo de edição com views não inicializadas");
            return;
        }

        if (isEditing) {
            // Se já está editando, cancelar
            cancelEdit();
        } else {
            // Entrar no modo de edição
            isEditing = true;

            try {
                //Alterar estados dos campos
                etNome.setEnabled(true);
                etEmail.setEnabled(true);
                etTelefone.setEnabled(true);
                etNomeSocial.setEnabled(true);

                // CPF sempre desabilitado (não pode ser alterado)
                etCpf.setEnabled(false);

                // Configurar validadores apenas quando entrar em modo de edição
                setupValidators();

                // Animar para modo de edição
                animateToEditMode();

                // Atualizar estado inicial do botão salvar
                updateSaveButtonState();
            } catch (Exception e) {
                android.util.Log.e("UserFragment", "Erro ao entrar no modo de edição: " + e.getMessage());
            }
        }
    }

    private void animateToEditMode() {
        if (btnSalvar == null || btnEditar == null || viewSpacing == null) {
            android.util.Log.e("UserFragment", "Botões não inicializados para animação");
            return;
        }

        // Tornar o botão salvar visível mas ainda sem largura
        btnSalvar.setVisibility(View.VISIBLE);
        btnSalvar.setAlpha(0f);

        // Obter os LayoutParams atuais
        LinearLayout.LayoutParams editarParams = (LinearLayout.LayoutParams) btnEditar.getLayoutParams();
        LinearLayout.LayoutParams salvarParams = (LinearLayout.LayoutParams) btnSalvar.getLayoutParams();
        LinearLayout.LayoutParams spacingParams = (LinearLayout.LayoutParams) viewSpacing.getLayoutParams();

        // Animar os weights
        ValueAnimator animator = ValueAnimator.ofFloat(0f, 1f);
        animator.setDuration(ANIMATION_DURATION);
        animator.setInterpolator(new AccelerateDecelerateInterpolator());

        animator.addUpdateListener(animation -> {
            float progress = animation.getAnimatedFraction();

            // Animar o weight do botão editar: de 1 para 0.48
            editarParams.weight = 1f - (progress * 0.52f);

            // Animar o weight do botão salvar: de 0 para 0.48
            salvarParams.weight = progress * 0.48f;

            // Animar o spacing: de 0 para 0.04 (4% da largura)
            spacingParams.weight = progress * 0.04f;

            // Animar alpha do botão salvar
            btnSalvar.setAlpha(progress);

            // Aplicar os novos parâmetros
            btnEditar.setLayoutParams(editarParams);
            btnSalvar.setLayoutParams(salvarParams);
            viewSpacing.setLayoutParams(spacingParams);

            // Mostrar o spacing quando começar a animação
            if (progress > 0f && viewSpacing.getVisibility() != View.VISIBLE) {
                viewSpacing.setVisibility(View.VISIBLE);
            }
        });

        // Animar mudança de background, texto e ícone do botão editar com fade
        animateButtonBackgroundTextAndIcon(btnEditar, "Cancelar", btn_gradient_danger, R.drawable.ic_close);

        animator.start();
    }

    private void animateToViewMode() {
        if (btnSalvar == null || btnEditar == null || viewSpacing == null) {
            android.util.Log.e("UserFragment", "Botões não inicializados para animação de volta");
            return;
        }

        // Obter os LayoutParams atuais
        LinearLayout.LayoutParams editarParams = (LinearLayout.LayoutParams) btnEditar.getLayoutParams();
        LinearLayout.LayoutParams salvarParams = (LinearLayout.LayoutParams) btnSalvar.getLayoutParams();
        LinearLayout.LayoutParams spacingParams = (LinearLayout.LayoutParams) viewSpacing.getLayoutParams();

        // Animar os weights de volta
        ValueAnimator animator = ValueAnimator.ofFloat(1f, 0f);
        animator.setDuration(ANIMATION_DURATION);
        animator.setInterpolator(new AccelerateDecelerateInterpolator());

        animator.addUpdateListener(animation -> {
            float progress = animation.getAnimatedFraction();

            // Animar o weight do botão editar: de 0.48 para 1
            editarParams.weight = 0.48f + (progress * 0.52f);

            // Animar o weight do botão salvar: de 0.48 para 0
            salvarParams.weight = 0.48f - (progress * 0.48f);

            // Animar o spacing: de 0.04 para 0
            spacingParams.weight = 0.04f - (progress * 0.04f);

            // Animar alpha do botão salvar
            btnSalvar.setAlpha(1f - progress);

            // Aplicar os novos parâmetros
            btnEditar.setLayoutParams(editarParams);
            btnSalvar.setLayoutParams(salvarParams);
            viewSpacing.setLayoutParams(spacingParams);
        });

        animator.addListener(new android.animation.AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(android.animation.Animator animation) {
                // Ocultar botão salvar e spacing ao final da animação
                btnSalvar.setVisibility(View.GONE);
                viewSpacing.setVisibility(View.GONE);
            }
        });

        // Animar mudança de background, texto e ícone do botão editar com fade
        animateButtonBackgroundTextAndIcon(btnEditar, "Editar", btn_gradient_primary, R.drawable.ic_edit);

        animator.start();
    }

    /**
     * Anima a mudança de background, texto e ícone do MaterialButton com transição direta suave
     */
    private void animateButtonBackgroundTextAndIcon(MaterialButton button, String newText, int newBackgroundRes, int newIconRes) {
        if (button == null || getContext() == null) {
            android.util.Log.e("UserFragment", "Button ou Context null na animação");
            return;
        }

        // Criar drawable do novo background e ícone
        final var newDrawable = AppCompatResources.getDrawable(getContext(), newBackgroundRes);
        final var newIcon = AppCompatResources.getDrawable(getContext(), newIconRes);

        // Transição suave de alpha do background atual
        ValueAnimator backgroundTransition = ValueAnimator.ofFloat(1f, 0f);
        backgroundTransition.setDuration(ANIMATION_DURATION);
        backgroundTransition.setInterpolator(new AccelerateDecelerateInterpolator());

        backgroundTransition.addUpdateListener(animation -> {
            float progress = animation.getAnimatedFraction();

            // Mudança suave do alpha do background atual
            if (progress <= 0.5f) {
                // Primeira metade: fade out do background atual
                int alpha = (int) (255 * (1f - progress * 2f));
                if (button.getBackground() != null) {
                    button.getBackground().setAlpha(Math.max(alpha, 50)); // Mínimo de 50 para não ficar totalmente transparente
                }
            } else {
                // Segunda metade: fade in do novo background + mudança de texto e ícone
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
                // Garantir que o alpha final seja 255 (totalmente opaco)
                if (button.getBackground() != null) {
                    button.getBackground().setAlpha(255);
                }
            }
        });

        backgroundTransition.start();
    }

    private void cancelEdit() {
        // Limpar erros antes de recarregar dados
        clearAllErrors();
        loadUserData(); // Recarregar dados originais
        exitEditMode(); // Sair do modo de edição sem toggle
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

    private void saveUserData() {
        if (!areViewsInitialized()) {
            android.util.Log.e("UserFragment", "Tentativa de salvar dados com views não inicializadas");
            return;
        }

        // Validar todos os campos antes de salvar
        if (!validateAllFields()) {
            Toast.makeText(getContext(), "Por favor, corrija os erros antes de salvar", Toast.LENGTH_SHORT).show();
            return;
        }

        // Desabilitar botão para evitar cliques duplos
        btnSalvar.setEnabled(false);
        btnSalvar.setText("Salvando...");

        try {
            // Coletar dados normalizados
            String nome = Utils.normalizarNome(etNome.getText().toString());
            String email = Utils.normalizarEmail(etEmail.getText().toString());
            String telefone = Utils.extrairNumeros(etTelefone.getText().toString());
            String nomeSocial = Utils.normalizarNome(etNomeSocial.getText().toString());

            // TODO: Salvar os dados no banco/API
            // Simular salvamento
            btnSalvar.postDelayed(() -> {
                Toast.makeText(getContext(), "Dados salvos com sucesso!", Toast.LENGTH_SHORT).show();

                // Restaurar texto do botão
                btnSalvar.setText("Salvar");
                btnSalvar.setEnabled(true);

                exitEditMode(); // Sair do modo de edição
            }, 1500);

        } catch (Exception e) {
            android.util.Log.e("UserFragment", "Erro ao salvar dados: " + e.getMessage());
            Toast.makeText(getContext(), "Erro ao salvar dados", Toast.LENGTH_SHORT).show();

            // Restaurar botão em caso de erro
            btnSalvar.setText("Salvar");
            btnSalvar.setEnabled(true);
        }
    }

    /**
     * Validação final de todos os campos editáveis
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

    private void exitEditMode() {
        if (!isEditing) return; // Já está no modo view

        if (!areViewsInitialized()) {
            android.util.Log.e("UserFragment", "Tentativa de sair do modo de edição com views não inicializadas");
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

            // Remover validadores (limpar listeners)
            removeValidators();

            // Animar volta ao modo view
            animateToViewMode();

            // Resetar flags de validação
            isNomeValido = true;
            isEmailValido = true;
            isTelefoneValido = true;
            isNomeSocialValido = true;
        } catch (Exception e) {
            android.util.Log.e("UserFragment", "Erro ao sair do modo de edição: " + e.getMessage());
        }
    }

    /**
     * Remove os validadores dos campos para evitar conflitos
     */
    private void removeValidators() {
        try {
            // Criar TextWatchers vazios para substituir os existentes
            TextWatcher emptyWatcher = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {}
                @Override
                public void afterTextChanged(Editable s) {}
            };

            // A maneira mais segura é recriar os EditTexts ou simplesmente não adicionar
            // novos listeners até que seja necessário novamente
        } catch (Exception e) {
            android.util.Log.e("UserFragment", "Erro ao remover validadores: " + e.getMessage());
        }
    }
}
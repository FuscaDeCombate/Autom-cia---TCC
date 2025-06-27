package com.automacia.mobile;

import static com.automacia.mobile.R.*;
import static com.automacia.mobile.R.drawable.btn_gradient_danger;
import static com.automacia.mobile.R.drawable.btn_gradient_primary;

import android.animation.ValueAnimator;
import android.graphics.drawable.DrawableContainer;
import android.os.Bundle;
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

import java.util.Objects;

public class UserFragment extends Fragment {

    // Views
    private ImageButton btnBack;
    private ImageView icProfilePhoto;
    private TextView tvChangePhoto;
    private TextInputEditText etNome, etCpf, etEmail, etTelefone, etNomeSocial;
    private MaterialButton btnEditar, btnSalvar;
    private View viewSpacing;
    private LinearLayout llButtonsContainer;

    private boolean isEditing = false;
    private static final int ANIMATION_DURATION = 300;

    public UserFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_user, container, false);

        initViews(view);
        setupClickListeners();
        loadUserData();

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
    }

    private void setupClickListeners() {
        btnBack.setOnClickListener(v -> {
            if (getActivity() != null) {
                getActivity().getOnBackPressedDispatcher().onBackPressed();
            }
        });

        tvChangePhoto.setOnClickListener(v -> {
            // TODO: Implementar seleção de foto
            Toast.makeText(getContext(), "Selecionar foto", Toast.LENGTH_SHORT).show();
        });

        btnEditar.setOnClickListener(v -> {
            if (isEditing) {
                cancelEdit();
            } else {
                toggleEditMode();
            }
        });

        btnSalvar.setOnClickListener(v -> saveUserData());
    }

    private void loadUserData() {
        //TODO: carregamento de dados reais do Banco
        // Simulação
        etNome.setText("João Silva");
        etCpf.setText("123.456.789-00");
        etEmail.setText("joao@email.com");
        etTelefone.setText("(11) 99999-9999");
        etNomeSocial.setText("");
    }

    private void toggleEditMode() {
        if (isEditing) {
            // Se já está editando, cancelar
            cancelEdit();
        } else {
            // Entrar no modo de edição
            isEditing = true;

            //Alterar estados dos campos
            etNome.setEnabled(true);
            etEmail.setEnabled(true);
            etTelefone.setEnabled(true);
            etNomeSocial.setEnabled(true);

            // CPF sempre desabilitado (não pode ser alterado)
            etCpf.setEnabled(false);

            // Animar para modo de edição
            animateToEditMode();
        }
    }

    private void animateToEditMode() {
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
                button.getBackground().setAlpha(Math.max(alpha, 50)); // Mínimo de 50 para não ficar totalmente transparente
            } else {
                // Segunda metade: fade in do novo background + mudança de texto e ícone
                if (progress >= 0.5f && !button.getText().toString().equals(newText)) {
                    button.setText(newText);
                    button.setBackground(newDrawable);
                    button.setIcon(newIcon);
                }
                int alpha = (int) (255 * ((progress - 0.5f) * 2f));
                button.getBackground().setAlpha(Math.min(alpha, 255));
            }
        });

        backgroundTransition.addListener(new android.animation.AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(android.animation.Animator animation) {
                // Garantir que o alpha final seja 255 (totalmente opaco)
                button.getBackground().setAlpha(255);
            }
        });

        backgroundTransition.start();
    }

    private void cancelEdit() {
        loadUserData(); // Recarregar dados originais
        exitEditMode(); // Sair do modo de edição sem toggle
    }

    private void saveUserData() {
        //TODO: Salvar os dados do usuario pelo banco
        // Validar dados
        if (validateFields()) {
            // Aqui você salvaria os dados no banco/API
            String nome = etNome.getText().toString().trim();
            String email = etEmail.getText().toString().trim();
            String telefone = etTelefone.getText().toString().trim();
            String nomeSocial = etNomeSocial.getText().toString().trim();

            // Simular salvamento
            Toast.makeText(getContext(), "Dados salvos com sucesso!", Toast.LENGTH_SHORT).show();

            exitEditMode(); // Sair do modo de edição
        }
    }

    private void exitEditMode() {
        if (!isEditing) return; // Já está no modo view

        isEditing = false;

        // Desabilitar campos
        etNome.setEnabled(false);
        etEmail.setEnabled(false);
        etTelefone.setEnabled(false);
        etNomeSocial.setEnabled(false);
        etCpf.setEnabled(false);

        // Animar volta ao modo view
        animateToViewMode();
    }

    private boolean validateFields() {
        // TODO: Implementar validação dos campos
        String nome = etNome.getText().toString().trim();
        String email = etEmail.getText().toString().trim();
        String telefone = etTelefone.getText().toString().trim();

        if (nome.isEmpty()) {
            etNome.setError("Nome é obrigatório");
            return false;
        }

        if (email.isEmpty()) {
            etEmail.setError("Email é obrigatório");
            return false;
        }

        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            etEmail.setError("Email inválido");
            return false;
        }

        if (telefone.isEmpty()) {
            etTelefone.setError("Telefone é obrigatório");
            return false;
        }

        return true;
    }
}
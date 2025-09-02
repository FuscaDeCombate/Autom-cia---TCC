package com.automacia.mobile;

import android.os.Bundle;
import android.view.View;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import com.automacia.mobile.fragments.SendCodeFragment;
import com.automacia.mobile.fragments.VerifyCodeFragment;
import com.automacia.mobile.fragments.ResetPasswordFragment;
import com.automacia.mobile.utils.Utils;
import com.google.android.material.appbar.MaterialToolbar;

/**
 * Activity responsável pelo fluxo de recuperação de senha
 * Gerencia 3 fragments: Enviar código, Verificar código e Redefinir senha
 */
public class ForgotPasswordActivity extends AppCompatActivity implements
        SendCodeFragment.OnCodeSentListener,
        VerifyCodeFragment.OnCodeVerifiedListener,
        ResetPasswordFragment.OnPasswordResetListener {

    // Constantes para identificar os fragments
    public static final String FRAGMENT_SEND_CODE = "send_code";
    public static final String FRAGMENT_VERIFY_CODE = "verify_code";
    public static final String FRAGMENT_RESET_PASSWORD = "reset_password";

    // Views
    private MaterialToolbar toolbar;

    // Dados compartilhados entre fragments
    private String userCpf;
    private String userEmail;
    private String verificationCode;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_forgot_password);

        setupWindowInsets();
        initializeViews();
        setupToolbar();
        handleIntentData();
        showSendCodeFragment();
    }

    /**
     * Configura as margens para telas edge-to-edge
     */
    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        View mainView = findViewById(R.id.main);
        Utils.applyGradientBackground(mainView);
    }

    /**
     * Inicializa as views
     */
    private void initializeViews() {
        toolbar = findViewById(R.id.toolbar);
    }

    /**
     * Configura a toolbar
     */
    private void setupToolbar() {
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("Recuperar Senha");
        }

        toolbar.setNavigationOnClickListener(v -> onBackPressed());
    }

    /**
     * Processa dados vindos da intent
     */
    private void handleIntentData() {
        String cpfPrefill = getIntent().getStringExtra("cpf_prefill");
        if (cpfPrefill != null && !cpfPrefill.isEmpty()) {
            userCpf = cpfPrefill;
        }
    }

    /**
     * Mostra o primeiro fragment (enviar código)
     */
    private void showSendCodeFragment() {
        SendCodeFragment fragment = SendCodeFragment.newInstance(userCpf);
        replaceFragment(fragment, FRAGMENT_SEND_CODE, false);
        updateToolbarTitle("Recuperar Senha");
    }

    /**
     * Substitui o fragment atual com animação suave
     */
    private void replaceFragment(Fragment fragment, String tag, boolean addToBackStack) {
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

        // Animações personalizadas
        transaction.setCustomAnimations(
                R.anim.slide_in_right,
                R.anim.slide_out_left,
                R.anim.slide_in_left,
                R.anim.slide_out_right
        );

        transaction.replace(R.id.fragment_container, fragment, tag);

        if (addToBackStack) {
            transaction.addToBackStack(tag);
        }

        transaction.commit();
    }

    /**
     * Atualiza o título da toolbar
     */
    private void updateToolbarTitle(String title) {
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(title);
        }
    }

    // Interface callbacks dos fragments

    @Override
    public void onCodeSent(String cpf, String email, String code) {
        this.userCpf = cpf;
        this.userEmail = email;
        this.verificationCode = code;

        // Navega para o fragment de verificação
        VerifyCodeFragment fragment = VerifyCodeFragment.newInstance(email, code);
        replaceFragment(fragment, FRAGMENT_VERIFY_CODE, true);
        updateToolbarTitle("Verificar Código");
    }

    @Override
    public void onCodeVerified() {
        // Navega para o fragment de redefinir senha
        ResetPasswordFragment fragment = ResetPasswordFragment.newInstance(userCpf);
        replaceFragment(fragment, FRAGMENT_RESET_PASSWORD, true);
        updateToolbarTitle("Nova Senha");
    }

    @Override
    public void onResendCodeRequested() {
        // Volta para o fragment de enviar código mantendo os dados
        SendCodeFragment fragment = SendCodeFragment.newInstance(userCpf);
        replaceFragment(fragment, FRAGMENT_SEND_CODE, false);
        updateToolbarTitle("Recuperar Senha");
    }

    @Override
    public void onPasswordReset() {
        // Senha redefinida com sucesso - volta para login
        setResult(RESULT_OK);
        finish();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    @Override
    public void onBackPressed() {
        Fragment currentFragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container);

        if (currentFragment instanceof ResetPasswordFragment) {
            // Se estiver na tela de redefinir senha, volta para verificar código
            getSupportFragmentManager().popBackStack();
            updateToolbarTitle("Verificar Código");
        } else if (currentFragment instanceof VerifyCodeFragment) {
            // Se estiver na tela de verificar código, volta para enviar código
            getSupportFragmentManager().popBackStack();
            updateToolbarTitle("Recuperar Senha");
        } else {
            // Se estiver na primeira tela, sai da activity
            super.onBackPressed();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    // Getters para os fragments acessarem os dados compartilhados
    public String getUserCpf() {
        return userCpf;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public String getVerificationCode() {
        return verificationCode;
    }
}
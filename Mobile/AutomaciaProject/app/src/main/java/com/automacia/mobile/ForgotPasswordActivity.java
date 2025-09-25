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

    // Tags dos fragments
    private static final String FRAGMENT_SEND_CODE = "send_code";
    private static final String FRAGMENT_VERIFY_CODE = "verify_code";
    private static final String FRAGMENT_RESET_PASSWORD = "reset_password";

    // Títulos das telas
    private static final String TITLE_RECOVER_PASSWORD = "Recuperar Senha";
    private static final String TITLE_VERIFY_CODE = "Verificar Código";
    private static final String TITLE_NEW_PASSWORD = "Nova Senha";

    private MaterialToolbar toolbar;
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
        showSendCodeFragment();
    }

    private void setupWindowInsets() {
        View mainView = findViewById(R.id.main);
        ViewCompat.setOnApplyWindowInsetsListener(mainView, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
        Utils.applyGradientBackground(mainView);
    }

    private void initializeViews() {
        toolbar = findViewById(R.id.toolbar);
    }

    private void setupToolbar() {
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle(TITLE_RECOVER_PASSWORD);
        }
        toolbar.setNavigationOnClickListener(v -> handleBackNavigation());
    }

    private void showSendCodeFragment() {
        SendCodeFragment fragment = SendCodeFragment.newInstance();
        replaceFragment(fragment, FRAGMENT_SEND_CODE);
        updateToolbarTitle(TITLE_RECOVER_PASSWORD);
    }

    private void replaceFragment(Fragment fragment, String tag) {
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

        transaction.setCustomAnimations(
                R.anim.slide_in_right,
                R.anim.slide_out_left,
                R.anim.slide_in_left,
                R.anim.slide_out_right
        );

        transaction.replace(R.id.fragment_container, fragment, tag);

        // Adiciona ao back stack apenas se não for o primeiro fragment
        if (!FRAGMENT_SEND_CODE.equals(tag)) {
            transaction.addToBackStack(tag);
        }

        transaction.commit();
    }

    private void updateToolbarTitle(String title) {
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(title);
        }
    }

    @Override
    public void onCodeVerified() {
        ResetPasswordFragment fragment = ResetPasswordFragment.newInstance(userEmail);
        replaceFragment(fragment, FRAGMENT_RESET_PASSWORD);
        updateToolbarTitle(TITLE_NEW_PASSWORD);
    }

    @Override
    public void onResendCodeRequested() {
        // Limpa o back stack e volta para o primeiro fragment
        getSupportFragmentManager().popBackStack(null, androidx.fragment.app.FragmentManager.POP_BACK_STACK_INCLUSIVE);
        showSendCodeFragment();
    }

    @Override
    public void onPasswordReset() {
        setResult(RESULT_OK);
        finish();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }

    private void handleBackNavigation() {
        Fragment currentFragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container);

        if (currentFragment instanceof ResetPasswordFragment) {
            getSupportFragmentManager().popBackStack();
            updateToolbarTitle(TITLE_VERIFY_CODE);
        } else if (currentFragment instanceof VerifyCodeFragment) {
            getSupportFragmentManager().popBackStack();
            updateToolbarTitle(TITLE_RECOVER_PASSWORD);
        } else {
            finish();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        handleBackNavigation();
    }

    @Override
    public void onCodeSent(String email, String code) {
        this.userEmail = email;
        this.verificationCode = code;

        VerifyCodeFragment fragment = VerifyCodeFragment.newInstance(email, code);
        replaceFragment(fragment, FRAGMENT_VERIFY_CODE);
        updateToolbarTitle(TITLE_VERIFY_CODE);
    }
}
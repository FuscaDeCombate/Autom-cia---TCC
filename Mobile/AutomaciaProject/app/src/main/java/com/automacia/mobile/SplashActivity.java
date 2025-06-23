package com.automacia.mobile;

import android.content.Intent;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class SplashActivity extends AppCompatActivity {

    // Constantes para melhor organização
    private static final int SPLASH_DURATION = 2000; // 2 segundos
    private static final int FADE_DURATION = 800;    // 800ms para fade out

    // Cores do gradiente
    private static final int COLOR_LIME_GREEN = 0xFF00FF00;
    private static final int COLOR_DARK_GREEN = 0xFF009933;
    private static final int COLOR_DARK_BLUE = 0xFF000080;

    private Handler splashHandler;
    private Runnable splashRunnable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Configuração para tela cheia
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_splash);

        setupWindowInsets();
        setupGradientBackground();
        startSplashSequence();
    }

    /**
     * Configura os insets da janela para compatibilidade com diferentes dispositivos
     */
    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.splash_root), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    /**
     * Cria e aplica o gradiente de fundo
     */
    private void setupGradientBackground() {
        ShapeDrawable.ShaderFactory shaderFactory = new ShapeDrawable.ShaderFactory() {
            @Override
            public Shader resize(int width, int height) {
                return new LinearGradient(
                        0, 0,
                        width * 0.7f, height * 0.7f,
                        new int[]{
                                COLOR_LIME_GREEN,     // Verde limão
                                COLOR_DARK_GREEN,     // Verde escuro intermediário
                                COLOR_DARK_BLUE       // Azul escuro
                        },
                        new float[]{
                                0.0f, 0.4f, 1.0f      // Distribuição das cores
                        },
                        Shader.TileMode.CLAMP
                );
            }
        };

        PaintDrawable paintDrawable = new PaintDrawable();
        paintDrawable.setShape(new RectShape());
        paintDrawable.setShaderFactory(shaderFactory);

        // Aplica o fundo na view raiz
        View rootView = findViewById(android.R.id.content);
        rootView.setBackground(paintDrawable);
    }

    /**
     * Inicia a sequência do splash screen
     */
    private void startSplashSequence() {
        splashRunnable = this::performFadeOutAndNavigate;
        splashHandler = new Handler(Looper.getMainLooper());
        splashHandler.postDelayed(splashRunnable, SPLASH_DURATION);
    }

    /**
     * Executa a animação de fade out e navega para a próxima tela
     */
    private void performFadeOutAndNavigate() {
        View splashView = findViewById(R.id.splash_root);

        if (splashView != null && !isFinishing()) {
            splashView.animate()
                    .alpha(0f)
                    .setDuration(FADE_DURATION)
                    .setInterpolator(new AccelerateInterpolator())
                    .withEndAction(this::navigateToLogin)
                    .start();
        } else {
            // Fallback caso a view não exista ou activity esteja finalizando
            navigateToLogin();
        }
    }

    /**
     * Navega para a tela de login
     */
    private void navigateToLogin() {
        if (!isFinishing()) {
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);

            // Adiciona transição suave entre activities
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Limpa o handler para evitar vazamentos de memória
        if (splashHandler != null && splashRunnable != null) {
            splashHandler.removeCallbacks(splashRunnable);
        }
    }

    @Override
    public void onBackPressed() {
        // Desabilita o botão voltar durante o splash
        // Opcional: você pode remover isso se quiser permitir sair do app
        super.onBackPressed();
    }
}
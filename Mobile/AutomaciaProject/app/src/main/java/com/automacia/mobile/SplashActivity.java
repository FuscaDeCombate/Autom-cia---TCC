package com.automacia.mobile;

import android.content.Intent;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.widget.Toast;

import com.automacia.mobile.services.RegisterService;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class SplashActivity extends AppCompatActivity {

    private static final String TAG = "SplashActivity";

    // Constantes para melhor organização
    private static final int SPLASH_DURATION = 2000; // 2 segundos
    private static final int FADE_DURATION = 800;    // 800ms para fade out

    // Cores do gradiente
    private static final int COLOR_LIME_GREEN = 0xFF00FF00;
    private static final int COLOR_DARK_GREEN = 0xFF009933;
    private static final int COLOR_DARK_BLUE = 0xFF000080;

    private Handler splashHandler;
    private Runnable splashRunnable;
    private RegisterService registerService;
    private boolean isProcessingDeepLink = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Inicializa o RegisterService
        registerService = new RegisterService(this);

        Intent intent = getIntent();
        String action = intent.getAction();
        Uri data = intent.getData();

        if (Intent.ACTION_VIEW.equals(action) && data != null) {
            // Usuário clicou no link de verificação
            isProcessingDeepLink = true;
            setupUIForDeepLink();
            processarLinkVerificacao(data.toString());
        } else {
            // Fluxo normal do splash
            setupNormalSplash();
        }
    }

    /**
     * Configura a UI para processamento de deep link
     */
    private void setupUIForDeepLink() {
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_splash);
        setupWindowInsets();
        setupGradientBackground();

        // Mostra uma mensagem de carregamento
        Toast.makeText(this, "Verificando email...", Toast.LENGTH_SHORT).show();
    }

    /**
     * Configura o splash normal
     */
    private void setupNormalSplash() {
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_splash);
        setupWindowInsets();
        setupGradientBackground();
        startSplashSequence();
    }

    /**
     * Processa o link de verificação recebido via deep link
     */
    private void processarLinkVerificacao(String linkRecebido) {
        Log.d(TAG, "Processando link de verificação: " + linkRecebido);

        if (registerService != null) {
            registerService.processarLinkVerificacao(linkRecebido, new RegisterService.RegisterCallback() {
                @Override
                public void onSuccess(String message) {
                    Log.d(TAG, "Link processado com sucesso: " + message);
                    runOnUiThread(() -> {
                        Toast.makeText(SplashActivity.this, message, Toast.LENGTH_LONG).show();

                        // Aguarda um pouco para o usuário ver a mensagem e vai para o login
                        new Handler(Looper.getMainLooper()).postDelayed(() -> {
                            navigateToLogin();
                        }, 2000);
                    });
                }

                @Override
                public void onError(String error) {
                    Log.e(TAG, "Erro ao processar link: " + error);
                    runOnUiThread(() -> {
                        Toast.makeText(SplashActivity.this, "Erro: " + error, Toast.LENGTH_LONG).show();

                        // Mesmo com erro, vai para o login após um tempo
                        new Handler(Looper.getMainLooper()).postDelayed(() -> {
                            navigateToLogin();
                        }, 2000);
                    });
                }

                @Override
                public void onLoading(boolean isLoading) {
                    // Pode mostrar/ocultar um indicador de loading se necessário
                    Log.d(TAG, "Loading: " + isLoading);
                }

                @Override
                public void onEmailVerificationSent(String email) {
                    // Não usado neste contexto
                }
            });
        } else {
            Log.e(TAG, "RegisterService não está inicializado");
            Toast.makeText(this, "Erro interno. Redirecionando...", Toast.LENGTH_SHORT).show();
            navigateToLogin();
        }
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
                                COLOR_LIME_GREEN,
                                COLOR_DARK_GREEN,
                                COLOR_DARK_BLUE
                        },
                        new float[]{
                                0.0f, 0.4f, 1.0f
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
        // Só faz a animação se não estiver processando deep link
        if (!isProcessingDeepLink) {
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
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        // Processa novos intents que chegarem enquanto a activity está ativa
        String action = intent.getAction();
        Uri data = intent.getData();

        if (Intent.ACTION_VIEW.equals(action) && data != null) {
            processarLinkVerificacao(data.toString());
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Limpa o handler para evitar vazamentos de memória
        if (splashHandler != null && splashRunnable != null) {
            splashHandler.removeCallbacks(splashRunnable);
        }

        // Libera recursos do RegisterService
        if (registerService != null) {
            registerService.shutdown();
        }
    }

    @Override
    public void onBackPressed() {
        // Desabilita o botão voltar durante o splash
        // Se estiver processando deep link, permite voltar
        if (isProcessingDeepLink) {
            super.onBackPressed();
        }
        // Senão, não faz nada (bloqueia o voltar durante o splash normal)
    }
}
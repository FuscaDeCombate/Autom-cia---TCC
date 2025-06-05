package com.automacia.mobile;

import android.content.Intent;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class SplashActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_splash);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.splash_root), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        ShapeDrawable.ShaderFactory shaderFactory = new ShapeDrawable.ShaderFactory() {
            @Override
            public Shader resize(int width, int height) {
                return new LinearGradient(
                        0, 0, width * 0.7f, height * 0.7f,
                        new int[]{
                                0xFF00FF00, // Verde limão
                                0xFF009933, // Verde escuro intermediário
                                0xFF000080  // Azul escuro
                        },
                        new float[]{
                                0.0f, 0.4f, 1.0f // Azul aparece a partir de ~40%
                        },
                        Shader.TileMode.CLAMP
                );
            }
        };


        PaintDrawable paint = new PaintDrawable();
        paint.setShape(new RectShape());
        paint.setShaderFactory(shaderFactory);

        View rootView = findViewById(android.R.id.content);
        rootView.setBackground(paint);

        new Handler().postDelayed(() -> {
            View splashView = findViewById(R.id.splash_root);
            splashView.animate()
                    .alpha(0f)
                    .setDuration(800)
                    .withEndAction(() -> {
                        startActivity(new Intent(getBaseContext(), LoginActivity.class));
                        finish();
                    });
        }, 2000);
    }
}
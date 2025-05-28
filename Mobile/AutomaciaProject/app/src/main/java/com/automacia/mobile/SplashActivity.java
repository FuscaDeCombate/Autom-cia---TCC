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
                        0, height, width, 0,
                        new int[]{
                                0xFF001A6E,
                                0xFF001A6E,
                                0xFF009061,
                                0xFF00DB00,
                                0xFF009B00,
                                0xFF009B00
                        },
                        new float[]{0.0f, 0.10f, 0.40f, 0.70f, 0.90f, 1.0f},
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
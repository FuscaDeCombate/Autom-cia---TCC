package com.automacia.mobile;

import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.os.Bundle;
import android.view.View;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class Login_screen extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login_screen);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        ShapeDrawable.ShaderFactory shaderFactory = new ShapeDrawable.ShaderFactory() {
            @Override
            public Shader resize(int width, int height) {
                LinearGradient linearGradient = new LinearGradient(
                        0,0, width, 0,
                        new int[] {
                                0xFF001A6E,
                                0xFF009061,
                                0xFF00DB00,
                                0xFF009B00,
                                0xFF009B00
                        },
                        new float[] {0.09f, 0.37f, 0.7f, 0.91f, 1.0f},
                        Shader.TileMode.CLAMP
                );
                return linearGradient;
            }
        };

        PaintDrawable paint = new PaintDrawable();
        paint.setShape(new RectShape());
        paint.setShaderFactory(shaderFactory);

        View rootView = findViewById(R.id.main);
        rootView.setBackground(paint);
    }
}
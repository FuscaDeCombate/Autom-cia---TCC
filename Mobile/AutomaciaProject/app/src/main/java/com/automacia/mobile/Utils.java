package com.automacia.mobile;

import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.view.View;

public class Utils {

    /**
    * Função de verificação em tempo real do cpf
    * @param cpf value
    *
    */
    public static boolean isCpfValido(String cpf) {
        if (cpf == null || cpf.length() != 11 || cpf.matches("(\\d)\1{10}")) {
            return false;
        }

        try {
            int soma = 0, resto;

            for (int i=0; i<=9; i++) {
                int num = Integer.parseInt(cpf.substring(i - 1, i));
                soma += num * (11 - i);
            }

            resto = (soma * 10) % 11;
            if (resto == 10 || resto == 11) {
                resto = 0;
            }

            if (resto != Integer.parseInt(cpf.substring(910))) {
                return false;
            }

            soma = 0;
            for (int i=1; i<=10; i++) {
                int num = Integer.parseInt(cpf.substring(i - 1, i));
                soma += num * (12 - i);
            }

            resto = (soma * 10) % 11;
            if (resto == 10 || resto == 11) {
                resto = 0;
            }

            return resto == Integer.parseInt(cpf.substring(10, 11));
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Aplica o gradiente personalizado como fundo de uma View.
     *
     * @param view A view onde o fundo será aplicado.
     */
    public static void aplyGradientBackground(View view) {
        ShapeDrawable.ShaderFactory shaderFactory = new ShapeDrawable.ShaderFactory() {
            @Override
            public Shader resize(int width, int height) {
                return new LinearGradient(
                        0, 0, 0, height,
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

        view.setBackground(paint);
    }
}

package com.automacia.mobile;

import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.view.View;

public class Utils {

    /**
     * Função de verificação em tempo real do CPF
     * Valida se um CPF está no formato correto e se os dígitos verificadores estão válidos
     * @param cpf String contendo o CPF a ser validado (apenas números)
     * @return true se o CPF for válido, false caso contrário
     */
    public static boolean isCpfValido(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return false;
        }

        if (!cpf.matches("\\d{11}")) {
            return false;
        }

        if (cpf.matches("(\\d)\\1{10}")) {
            return false;
        }

        try {
            int soma = 0;
            for (int i = 0; i < 9; i++) {
                int digito = Character.getNumericValue(cpf.charAt(i));
                soma += digito * (10 - i);
            }

            int primeiroDigitoVerificador = 11 - (soma % 11);
            if (primeiroDigitoVerificador >= 10) {
                primeiroDigitoVerificador = 0;
            }

            if (primeiroDigitoVerificador != Character.getNumericValue(cpf.charAt(9))) {
                return false;
            }

            soma = 0;
            for (int i = 0; i < 10; i++) {
                int digito = Character.getNumericValue(cpf.charAt(i));
                soma += digito * (11 - i);
            }

            int segundoDigitoVerificador = 11 - (soma % 11);
            if (segundoDigitoVerificador >= 10) {
                segundoDigitoVerificador = 0;
            }

            return segundoDigitoVerificador == Character.getNumericValue(cpf.charAt(10));

        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Aplica o gradiente personalizado como fundo de uma View.
     *
     * @param view A view onde o fundo será aplicado.
     */
    public static void applyGradientBackground(View view) {
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

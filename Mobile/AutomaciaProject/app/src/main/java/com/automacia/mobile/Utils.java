package com.automacia.mobile;

import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.util.Patterns;
import android.view.View;

import kotlin.contracts.Returns;

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
     * Valida se um nome está no formato correto
     * Verifica se o nome não está vazio, tem pelo menos 2 caracreres e contém apenas letras
     * @param nome String contendo o nome a ser validado
     * @return String com mensagme de erro ou null se válido
     */
    public static String validarNome(String nome) {
        if (nome == null || nome.trim().isEmpty()) {
            return "Nome é Obrigatorio";
        }

        nome = nome.trim();

        if (nome.length() < 2) {
            return "Nome muito curto";
        }

        if (!nome.matches("^[a-zA-ZÀ-ÿ\\s]+$")) {
            return "Nome deve conter apenas letras";
        }

        return null; // Válido
    }

    /**
     * Validad se um CPF está no formato correto
     * Verifica se o CPF não está vazio, tem 11 dígitos e possui digitos verificadores válidos
     * @param cpfFormatado String contendo o CPF formatado (com ou sem máscara)
     * @return String com mensagem de erro ou null se válido
     */
    public static String validarCpf(String cpfFormatado) {
        if (cpfFormatado == null || cpfFormatado.trim().isEmpty()) {
            return "CPF é obrigatório";
        }

        String cpfNumeros = cpfFormatado.replaceAll("[^\\d]", "");

        if (cpfNumeros.length() < 11) {
            return null; // Não mostra ero enquanto digita
        }

        if (cpfNumeros.length() > 11) {
            return "CPF inválido";
        }

        if (!isCpfValido(cpfNumeros)) {
            return "CPF inválido";
        }

        return null; // Válido
    }

    /**
     * Valida se um email está no formato correto
     * Verfica se o email não está vazio e segue o padrão de mail válido
     * @param email String contendo o email a ser válido
     * @return String com mensagem de erro ou null se válido
     */
    public static String validarEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return  "E-mail é obrigatório";
        }

        email = email.trim();

        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            return "E-mail inválido";
        }

        return null; // Válido
    }

    /**
     * Valida se um telefone está no formato correto
     * Verifica se o telefone não está vazio e tem entre 10 e 11 digitos
     * @param telefoneFormatado String contendo o telefone formatado (com ou sem máscara)
     * @return String com mensagem de erro ou null se válido
     */
    public static String validarTelefone(String telefoneFormatado) {
        if (telefoneFormatado == null || telefoneFormatado.trim().isEmpty()) {
            return "Telefone é obrigatório";
        }

        String telefoneNumeros = telefoneFormatado.replaceAll("[^\\d]", "");

        if (telefoneNumeros.length() < 10) {
            return null; //Não mostra erro enquanto digita
        }

        if (telefoneNumeros.length() > 11) {
            return "Telefone inválido";
        }

        return null; // Válido
    }

    /**
     * Valida se uma senha está no formato correto
     * Verifica se a senha não está vazia, tem pelos menos 6 caracteres e contém pelo menos uma letra
     * @param senha String contendo a senha a ser validada
     * @return String com mensagem de erro ou null se válido
     */
    // TODO: Adicionar mais requisitos de senha
    public static String validarSenha(String senha) {
        if (senha == null || senha.isEmpty()) {
            return "Senha é obrigatória";
        }

        if (senha.length() < 6) {
            return "Senha deve ter pelos menos 6 caracteres";
        }

        if (!senha.matches(".*[a-zA-Z].*")) {
            return "Senha deve conter pelos menos uma letra";
        }

        return null; // Válido
    }

    /**
     * Valida se confirmação de senha está correta
     * Verifica se a confirmação não está vazia e se conincide com a senha original
     * @param senha String contendo a senha original
     * @return String com mensagem de rro ou null se válido
     */
    public static String validarConfirmacaoSenha(String senha, String confirmacao) {
        if (confirmacao == null || confirmacao.isEmpty()) {
            return "Confirmação de senha é obrigatória";
        }

        if (!senha.equals(confirmacao)) {
            return "As senhas não coincidem";
        }

        return null; // Válido
    }

    /**
     * Verfica se um cmapo está vazio (considerando espaços em branco)
     * @param campo String contendo o campo a ser verificado
     * @return true se o campo estiver vazio, false caso contrário
     */
    public static boolean isCampoVazio(String campo) {
        return campo == null || campo.trim().isEmpty();
    }

    /**
     * Remove todos os caracteres não número de uma string
     * útil para limpar CPF, telefone e outros campos formatados
     * @param texto String contendo o texto a ser limpo
     * @return String contendo apenas números
     */
    public static String extrairNumeros(String texto) {
        if (texto == null) {
            return "";
        }

        return texto.replaceAll("[^\\d]", "");
    }

    /**
     * Normaliza um email removendo espaços e convertendo para minúsculas
     * @param email String contendo o email a ser normalizado
     * @return String com o email normalizado
     */
    // TODO: Verificar a real necessidade de uma normalização de email
    public static String normalizarEmail(String email) {
        if (email == null) {
            return "";
        }

        return email.trim().toLowerCase();
    }

    /**
     * Normaliza um nome removendo espaços extras capitalizando adequadamente
     * @param nome String contendo o nome a ser normalizado
     * @return String com o nome normalizado
     */
    public static String normalizarNome(String nome) {
        if (nome == null || nome.trim().isEmpty()) {
            return "";
        }

        // Remove espaços extras e converte para formato adequado
        nome = nome.trim().replaceAll("\\s+", "");

        //Capitaliza primeira letra de cada palavra
        String[] palavras = nome.split(" ");
        StringBuilder nomeNormalizado = new StringBuilder();

        for (int i=0;i<palavras.length;i++) {
            if (i > 0) {
                nomeNormalizado.append(" ");
            }

            String palavra = palavras[0].toLowerCase();
            if (palavra.length() > 0) {
                nomeNormalizado.append((Character.toUpperCase(palavra.charAt(0))));
                if (palavra.length() > 1) {
                    nomeNormalizado.append((palavra.substring(1)));
                }
            }
        }

        return nomeNormalizado.toString();
    }

    /**
     * Valida múltiplos campos de uma vez retorna o primeiro erro encontrado
     * @param validacoes Array de strings com os resultados as validações
     * @return String com a primeira mensagme de erro ecnotrada ou null se todo forem válidos
     */

    public static String validarCampo(String... validacoes) {
        for (String validacao : validacoes) {
            if (validacao != null) {
                return validacao;
            }
        }
        return null;
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

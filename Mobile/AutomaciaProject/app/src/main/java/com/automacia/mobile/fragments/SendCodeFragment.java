package com.automacia.mobile.fragments;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.automacia.mobile.R;
import com.automacia.mobile.utils.Utils;
import com.automacia.mobile.watchers.CpfMaskWatcher;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import java.util.Random;

/**
 * Fragment responsável por solicitar o código de recuperação
 * Permite ao usuário inserir CPF para receber código por email
 */
public class SendCodeFragment extends Fragment {

    private static final String ARG_CPF_PREFILL = "cpf_prefill";

    // Views
    private TextInputEditText editCpf;
    private TextInputLayout layoutCpf;
    private MaterialButton btnEnviarCodigo;
    private TextView txtDescricao;

    // Listener para comunicação com a Activity
    private OnCodeSentListener listener;

    // Validação
    private boolean isCpfValid = false;

    // CPF pré-preenchido (vindo do login)
    private String cpfPrefill;

    /**
     * Interface para comunicação com a Activity
     */
    public interface OnCodeSentListener {
        void onCodeSent(String cpf, String email, String code);
    }

    /**
     * Método factory para criar instância do fragment
     */
    public static SendCodeFragment newInstance(String cpfPrefill) {
        SendCodeFragment fragment = new SendCodeFragment();
        Bundle args = new Bundle();
        if (cpfPrefill != null) {
            args.putString(ARG_CPF_PREFILL, cpfPrefill);
        }
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof OnCodeSentListener) {
            listener = (OnCodeSentListener) context;
        } else {
            throw new RuntimeException(context.toString() + " deve implementar OnCodeSentListener");
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            cpfPrefill = getArguments().getString(ARG_CPF_PREFILL);
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_send_code, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initializeViews(view);
        setupValidators();
        setupClickListeners();
        prefillCpfIfAvailable();
    }

    /**
     * Inicializa as views
     */
    private void initializeViews(View view) {
        editCpf = view.findViewById(R.id.editCpf);
        layoutCpf = view.findViewById(R.id.layoutCpf);
        btnEnviarCodigo = view.findViewById(R.id.btnEnviarCodigo);
        txtDescricao = view.findViewById(R.id.txtDescricao);

        updateButtonState();
    }

    /**
     * Configura os validadores usando Utils
     */
    private void setupValidators() {
        // Aplica máscara de CPF
        editCpf.addTextChangedListener(new CpfMaskWatcher(editCpf));

        // Validação do CPF usando Utils
        editCpf.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarCpf(s.toString());
                layoutCpf.setError(erro);

                String cpfNumeros = Utils.extrairNumeros(s.toString());
                isCpfValid = (erro == null && cpfNumeros.length() == 11);

                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnEnviarCodigo.setOnClickListener(v -> sendVerificationCode());
    }

    /**
     * Preenche o CPF se foi passado da tela de login
     */
    private void prefillCpfIfAvailable() {
        if (cpfPrefill != null && !cpfPrefill.isEmpty()) {
            // Formata o CPF com máscara
            String cpfFormatado = formatCpfWithMask(cpfPrefill);
            editCpf.setText(cpfFormatado);
            editCpf.setSelection(cpfFormatado.length());
        }
    }

    /**
     * Formata CPF com máscara XXX.XXX.XXX-XX
     */
    private String formatCpfWithMask(String cpf) {
        if (cpf.length() != 11) return cpf;

        return cpf.substring(0, 3) + "." +
                cpf.substring(3, 6) + "." +
                cpf.substring(6, 9) + "-" +
                cpf.substring(9, 11);
    }

    /**
     * Atualiza o estado do botão
     */
    private void updateButtonState() {
        btnEnviarCodigo.setEnabled(isCpfValid);
        btnEnviarCodigo.setAlpha(isCpfValid ? 1.0f : 0.6f);
    }

    /**
     * Envia o código de verificação
     */
    private void sendVerificationCode() {
        if (!isCpfValid) {
            Toast.makeText(getContext(), "Por favor, insira um CPF válido", Toast.LENGTH_SHORT).show();
            return;
        }

        String cpfNumeros = Utils.extrairNumeros(editCpf.getText().toString());

        // Mostrar loading
        btnEnviarCodigo.setEnabled(false);
        btnEnviarCodigo.setText("Enviando...");

        // Simular chamada de API
        simulateApiCall(cpfNumeros);
    }

    /**
     * Simula chamada de API para enviar código
     */
    private void simulateApiCall(String cpf) {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            // Simular resposta da API
            String email = getSimulatedEmail(cpf);
            String verificationCode = generateRandomCode();

            if (listener != null) {
                listener.onCodeSent(cpf, email, verificationCode);
            }

            // Reset button
            btnEnviarCodigo.setEnabled(true);
            btnEnviarCodigo.setText("Enviar Código");

            Toast.makeText(getContext(),
                    "Código enviado para " + maskEmail(email),
                    Toast.LENGTH_LONG).show();

        }, 2000); // 2 segundos de delay
    }

    /**
     * Simula busca do email do usuário baseado no CPF
     */
    private String getSimulatedEmail(String cpf) {
        // Em uma implementação real, isso viria da API
        return "usuario@email.com";
    }

    /**
     * Gera código aleatório de 6 dígitos
     */
    private String generateRandomCode() {
        //Random random = new Random();
        //return String.format("%06d", random.nextInt(1000000));
        return "123456"; // Código fixo para testes
    }

    /**
     * Mascara o email para exibição
     */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }

        String[] parts = email.split("@");
        String username = parts[0];
        String domain = parts[1];

        if (username.length() <= 2) {
            return email;
        }

        String maskedUsername = username.substring(0, 2) +
                "*".repeat(username.length() - 2);

        return maskedUsername + "@" + domain;
    }

    @Override
    public void onDetach() {
        super.onDetach();
        listener = null;
    }
}
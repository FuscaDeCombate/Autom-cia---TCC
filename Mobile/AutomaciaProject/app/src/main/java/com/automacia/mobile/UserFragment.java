package com.automacia.mobile;

import static com.automacia.mobile.R.*;
import static com.automacia.mobile.R.drawable.btn_gradient_danger;
import static com.automacia.mobile.R.drawable.btn_gradient_primary;

import android.graphics.drawable.DrawableContainer;
import android.os.Bundle;

import androidx.appcompat.content.res.AppCompatResources;
import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.textfield.TextInputEditText;

import java.util.Objects;

public class UserFragment extends Fragment {

    // Views
    private ImageButton btnBack;
    private ImageView icProfilePhoto;
    private TextView tvChangePhoto;
    private TextInputEditText etNome, etCpf, etEmail, etTelefone, etNomeSocial;
    private Button btnEditar, btnSalvar;

    private boolean isEditing = false;

    public UserFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_user, container, false);

        initViews(view);
        setupClickListeners();
        loadUserData();

        return view;
    }

    private void initViews(View view) {
        btnBack = view.findViewById(R.id.btn_back);
        icProfilePhoto = view.findViewById(R.id.iv_profile_photo);
        tvChangePhoto = view.findViewById(R.id.tv_change_photo);
        etNome = view.findViewById(R.id.et_nome);
        etCpf = view.findViewById(R.id.et_cpf);
        etEmail = view.findViewById(R.id.et_email);
        etTelefone = view.findViewById(R.id.et_telefone);
        etNomeSocial = view.findViewById(R.id.et_nome_social);
        btnEditar = view.findViewById(R.id.btn_editar);
        btnSalvar = view.findViewById(R.id.btn_salvar);
    }

    private void setupClickListeners() {
        btnBack.setOnClickListener(v -> {
            if (getActivity() != null) {
                getActivity().getOnBackPressedDispatcher().onBackPressed();
            }
        });

        tvChangePhoto.setOnClickListener(v -> {
            // TODO: Implementar seleção de foto
            Toast.makeText(getContext(), "Selecionar foto", Toast.LENGTH_SHORT).show();
        });

        btnEditar.setOnClickListener(v -> {
            if (isEditing) {
                cancelEdit();
            } else {
                toggleEditMode();
            }
        });

        btnSalvar.setOnClickListener(v -> saveUserData());
    }

    private void loadUserData() {
        //TODO: carregamento de dados reais do Banco
        // Simulação
        etNome.setText("João Silva");
        etCpf.setText("123.456.789-00");
        etEmail.setText("joao@email.com");
        etTelefone.setText("(11) 99999-9999");
        etNomeSocial.setText("");
    }

    private void toggleEditMode() {
        isEditing = !isEditing;

        //Alterar estados dos campos
        etNome.setEnabled(isEditing);
        etEmail.setEnabled(isEditing);
        etTelefone.setEnabled(isEditing);
        etNomeSocial.setEnabled(isEditing);

        // CPF sempre desabilitado (não pode ser alterado)
        etCpf.setEnabled(false);

        // Mostrar/Ocultar botões
        if (isEditing) {
            btnEditar.setBackground(AppCompatResources.getDrawable(getContext(), btn_gradient_danger));
            btnEditar.setText("Cancelar");
            btnSalvar.setVisibility(View.VISIBLE);
        } else {
            btnEditar.setBackground(AppCompatResources.getDrawable(getContext(), btn_gradient_primary));
            btnEditar.setText("Editar");
            btnSalvar.setVisibility(View.GONE);
        }
    }

    private void cancelEdit() {
        isEditing = false;
        loadUserData(); // Recarregar dados originais
        toggleEditMode();
    }

    private void saveUserData() {
        //TODO: Salvar os dados do usuario pelo banco
        // Validar dados
        if (validateFields()) {
            // Aqui você salvaria os dados no banco/API
            String nome = etNome.getText().toString().trim();
            String email = etEmail.getText().toString().trim();
            String telefone = etTelefone.getText().toString().trim();
            String nomeSocial = etNomeSocial.getText().toString().trim();

            // Simular salvamento
            Toast.makeText(getContext(), "Dados salvos com sucesso!", Toast.LENGTH_SHORT).show();

            btnEditar.setBackground(AppCompatResources.getDrawable(getContext(), btn_gradient_primary));
            toggleEditMode(); // Sair do modo de edição
        }
    }

    private boolean validateFields() {
        // TODO: Implementar validação dos campos
        String nome = etNome.getText().toString().trim();
        String email = etEmail.getText().toString().trim();
        String telefone = etTelefone.getText().toString().trim();

        if (nome.isEmpty()) {
            etNome.setError("Nome é obrigatório");
            return false;
        }

        if (email.isEmpty()) {
            etEmail.setError("Email é obrigatório");
            return false;
        }

        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            etEmail.setError("Email inválido");
            return false;
        }

        if (telefone.isEmpty()) {
            etTelefone.setError("Telefone é obrigatório");
            return false;
        }

        return true;
    }
}
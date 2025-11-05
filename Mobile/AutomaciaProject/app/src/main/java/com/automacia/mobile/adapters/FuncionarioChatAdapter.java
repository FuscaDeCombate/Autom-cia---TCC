package com.automacia.mobile.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.FuncionarioChatDTO;

import java.util.ArrayList;
import java.util.List;

public class FuncionarioChatAdapter extends RecyclerView.Adapter<FuncionarioChatAdapter.FuncionarioViewHolder> {
    private List<FuncionarioChatDTO> funcionarios;
    private OnItemClickListener onItemClickListener;

    // Interface para callback de clique
    public interface OnItemClickListener {
        void OnItemClick(FuncionarioChatDTO funcionario);
    }

    // Construtor
    public FuncionarioChatAdapter(OnItemClickListener listener) {
        this.funcionarios = new ArrayList<>();
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public FuncionarioViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_funcionario_chat, parent, false);
        return new FuncionarioViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull FuncionarioViewHolder holder, int position) {
        FuncionarioChatDTO funcionario = funcionarios.get(position);
        holder.bind(funcionario, onItemClickListener);
    }

    @Override
    public int getItemCount() {
        return funcionarios.size();
    }

    // Metodo para atualizar a lista
    public void setFuncionarios(List<FuncionarioChatDTO> novalista) {
        this.funcionarios.clear();

        // Filtar apenas funcionarios ativos
        for (FuncionarioChatDTO func : novalista) {
            if (func.isAtivo() && !isAdministrador(func.getTipoFuncionario())) {
                this.funcionarios.add(func);
            }
         }

        notifyDataSetChanged();
    }

    // Metodo para adicionar um funcionario
    public void addFuncionario(FuncionarioChatDTO funcionario) {
        if (funcionario.isAtivo() && !isAdministrador(funcionario.getTipoFuncionario())) {
            this.funcionarios.add(funcionario);
            notifyItemInserted(funcionarios.size() -1);
        }
    }

    public void clearFuncionarios() {
        this.funcionarios.clear();
        notifyDataSetChanged();
    }

    // Metodo auxiliar para verificar se é administrador
    private boolean isAdministrador(String tipoFuncionario) {
        if (tipoFuncionario == null) return false;

        String tipo = tipoFuncionario.toLowerCase().trim();
        return tipo.contains("administrador");
    }


    // === ViewHolder
    static class FuncionarioViewHolder extends RecyclerView.ViewHolder {
        private TextView tvNomeFuncionario;
        private TextView tvTipoFuncionario;
        private TextView tvHospital;
        private View badgeChatAberto;
        private ImageView ivFuncionarioAvatar;

        public FuncionarioViewHolder(@NonNull View itemView) {
            super(itemView);

            tvNomeFuncionario = itemView.findViewById(R.id.tvNomeFuncionario);
            tvTipoFuncionario = itemView.findViewById(R.id.tvTipoFuncionario);
            tvHospital = itemView.findViewById(R.id.tvHospital);
            badgeChatAberto = itemView.findViewById(R.id.badgeChatAberto);
            ivFuncionarioAvatar = itemView.findViewById(R.id.ivFuncionarioAvatar);
        }

        public void bind(final FuncionarioChatDTO funcionario, final OnItemClickListener listener) {
            // Configura os dados
            tvNomeFuncionario.setText(funcionario.getNomeFuncionario());
            tvTipoFuncionario.setText(funcionario.getTipoFuncionario());
            tvHospital.setText(funcionario.getHospital());

            // Mostra badge se chat estiver aberto
            badgeChatAberto.setVisibility(funcionario.isChatAberto() ? View.VISIBLE : View.GONE);

            // Configura o avatar baseado no tipo de funcionário
            configurarAvatar(funcionario.getTipoFuncionario());

            // Click listener
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (listener != null) {
                        listener.OnItemClick(funcionario);
                    }
                }
            });
        }

        private void configurarAvatar(String tipoFuncionario) {
            if (tipoFuncionario == null) return;

            String tipo = tipoFuncionario.toLowerCase().trim();

            // Define ícone diferente baseado no tipo
            if (tipo.contains("saúde") || tipo.contains("saude")) {
                // Ícone para funcionário de saúde (ex: médico/enfermeiro)
                ivFuncionarioAvatar.setImageResource(R.drawable.ic_doctor);
            } else if (tipo.contains("farmácia") || tipo.contains("farmacia")) {
                // Ícone para funcionário de farmácia
                ivFuncionarioAvatar.setImageResource(R.drawable.ic_pharmacy);
            } else {
                // Ícone padrão
                ivFuncionarioAvatar.setImageResource(R.drawable.ic_person);
            }
        }
    }
}

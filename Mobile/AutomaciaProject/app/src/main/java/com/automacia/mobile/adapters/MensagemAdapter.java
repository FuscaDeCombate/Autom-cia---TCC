package com.automacia.mobile.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.MensagemDTO;

import java.util.ArrayList;
import java.util.List;

public class MensagemAdapter extends RecyclerView.Adapter<MensagemAdapter.MensagemViewHolder> {

    private List<MensagemDTO> mensagens;

    public MensagemAdapter() {
        this.mensagens = new ArrayList<>();
    }

    @NonNull
    @Override
    public MensagemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_mensagem, parent, false);
        return new MensagemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull MensagemViewHolder holder, int position) {
        MensagemDTO mensagem = mensagens.get(position);
        holder.bind(mensagem, position > 0 ? mensagens.get(position - 1) : null);
    }

    @Override
    public int getItemCount() {
        return mensagens.size();
    }

    public void adicionarMensagem(MensagemDTO mensagem) {
        mensagens.add(mensagem);
        notifyItemInserted(mensagens.size() - 1);
    }

    public void definirMensagens(List<MensagemDTO> novasMensagens) {
        this.mensagens.clear();
        this.mensagens.addAll(novasMensagens);
        notifyDataSetChanged();
    }

    public void limparMensagens() {
        this.mensagens.clear();
        notifyDataSetChanged();
    }

    public static class MensagemViewHolder extends RecyclerView.ViewHolder {

        private LinearLayout layoutMensagemPaciente;
        private LinearLayout layoutMensagemFuncionario;
        private LinearLayout layoutSeparadorData;

        private TextView tvMensagemPaciente;
        private TextView tvHoraPaciente;
        private TextView tvMensagemFuncionario;
        private TextView tvHoraFuncionario;
        private TextView tvSeparadorData;

        public MensagemViewHolder(@NonNull View itemView) {
            super(itemView);

            layoutMensagemPaciente = itemView.findViewById(R.id.layoutMensagemPaciente);
            layoutMensagemFuncionario = itemView.findViewById(R.id.layoutMensagemFuncionario);
            layoutSeparadorData = itemView.findViewById(R.id.layoutSeparadorData);

            tvMensagemPaciente = itemView.findViewById(R.id.tvMensagemPaciente);
            tvHoraPaciente = itemView.findViewById(R.id.tvHoraPaciente);
            tvMensagemFuncionario = itemView.findViewById(R.id.tvMensagemFuncionario);
            tvHoraFuncionario = itemView.findViewById(R.id.tvHoraFuncionario);
            tvSeparadorData = itemView.findViewById(R.id.tvSeparadorData);
        }

        public void bind(MensagemDTO mensagem, MensagemDTO mensagemAnterior) {
            // Reset visibility
            layoutMensagemPaciente.setVisibility(View.GONE);
            layoutMensagemFuncionario.setVisibility(View.GONE);
            layoutSeparadorData.setVisibility(View.GONE);

            // Mostrar separador de data se necessário
            boolean mostrarSeparador = false;
            if (mensagemAnterior == null || !mensagem.isMesmoData(mensagemAnterior)) {
                mostrarSeparador = true;
                layoutSeparadorData.setVisibility(View.VISIBLE);
                tvSeparadorData.setText(mensagem.getDataRelativa());
            }

            if (mensagem.isEhPaciente()) {
                // Mensagem do paciente (direita)
                layoutMensagemPaciente.setVisibility(View.VISIBLE);
                tvMensagemPaciente.setText(mensagem.getMensagem());
                tvHoraPaciente.setText(mensagem.getHoraFormatada());
            } else {
                // Mensagem do funcionário (esquerda)
                layoutMensagemFuncionario.setVisibility(View.VISIBLE);
                tvMensagemFuncionario.setText(mensagem.getMensagem());
                tvHoraFuncionario.setText(mensagem.getHoraFormatada());
            }
        }
    }
}
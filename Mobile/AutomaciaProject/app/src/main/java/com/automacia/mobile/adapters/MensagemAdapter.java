package com.automacia.mobile.adapters;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.MensagemDTO;

import java.util.ArrayList;
import java.util.List;

public class MensagemAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    // Constantes para tipos de view
    private static final int TIPO_MENSAGEM_PACIENTE = 1;
    private static final int TIPO_MENSAGEM_FUNCIONARIO = 2;
    private static final int TIPO_SEPARADOR_DATA = 3;

    private final List<ItemChat> itens;

    public MensagemAdapter() {
        this.itens = new ArrayList<>();
    }

    @Override
    public int getItemViewType(int position) {
        ItemChat item = itens.get(position);

        if (item.isSeparadorData()) {
            return TIPO_SEPARADOR_DATA;
        } else if (item.getMensagem().isEhPaciente()) {
            return TIPO_MENSAGEM_PACIENTE;
        } else {
            return TIPO_MENSAGEM_FUNCIONARIO;
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());

        switch (viewType) {
            case TIPO_MENSAGEM_PACIENTE:
                View viewPaciente = inflater.inflate(R.layout.item_mensagem_paciente, parent, false);
                return new MensagemPacienteViewHolder(viewPaciente);

            case TIPO_MENSAGEM_FUNCIONARIO:
                View viewFuncionario = inflater.inflate(R.layout.item_mensagem_funcionario, parent, false);
                return new MensagemFuncionarioViewHolder(viewFuncionario);

            case TIPO_SEPARADOR_DATA:
                View viewData = inflater.inflate(R.layout.item_mensagem_data, parent, false);
                return new SeparadorDataViewHolder(viewData);

            default:
                throw new IllegalArgumentException("Tipo de view desconhecido: " + viewType);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ItemChat item = itens.get(position);

        if (holder instanceof MensagemPacienteViewHolder) {
            ((MensagemPacienteViewHolder) holder).bind(item.getMensagem());
        } else if (holder instanceof MensagemFuncionarioViewHolder) {
            ((MensagemFuncionarioViewHolder) holder).bind(item.getMensagem());
        } else if (holder instanceof SeparadorDataViewHolder) {
            ((SeparadorDataViewHolder) holder).bind(item.getDataSeparador());
        }
    }

    @Override
    public int getItemCount() {
        return itens.size();
    }

    /**
     * Adiciona uma mensagem e automaticamente insere separador de data se necessário
     */
    public void adicionarMensagem(MensagemDTO mensagem) {
        Log.d("MensagemAdapter", "Adicionando mensagem: '" + mensagem.getMensagem() +
                "' | ehPaciente=" + mensagem.isEhPaciente());

        // Verifica se precisa adicionar separador de data
        if (itens.isEmpty()) {
            // Primeira mensagem: adiciona separador
            itens.add(new ItemChat(mensagem.getDataRelativa()));
            itens.add(new ItemChat(mensagem));
            notifyItemRangeInserted(itens.size() - 2, 2);
        } else {
            // Verifica se a última mensagem é do mesmo dia
            MensagemDTO ultimaMensagem = getUltimaMensagem();

            if (ultimaMensagem != null && !mensagem.isMesmoData(ultimaMensagem)) {
                // Dias diferentes: adiciona separador antes da nova mensagem
                itens.add(new ItemChat(mensagem.getDataRelativa()));
                itens.add(new ItemChat(mensagem));
                notifyItemRangeInserted(itens.size() - 2, 2);
            } else {
                // Mesmo dia: apenas adiciona a mensagem
                itens.add(new ItemChat(mensagem));
                notifyItemInserted(itens.size() - 1);
            }
        }

        Log.d("MensagemAdapter", "Total de mensagens agora: " + itens.size());
    }

    /**
     * Define lista completa de mensagens, processando separadores automaticamente
     */
    public void definirMensagens(List<MensagemDTO> mensagens) {
        itens.clear();

        if (mensagens.isEmpty()) {
            notifyDataSetChanged();
            return;
        }

        MensagemDTO mensagemAnterior = null;

        for (MensagemDTO mensagem : mensagens) {
            // Adiciona separador se for primeira mensagem ou data diferente
            if (mensagemAnterior == null || !mensagem.isMesmoData(mensagemAnterior)) {
                itens.add(new ItemChat(mensagem.getDataRelativa()));
            }

            // Adiciona a mensagem
            itens.add(new ItemChat(mensagem));
            mensagemAnterior = mensagem;
        }

        notifyDataSetChanged();
    }

    public void limparMensagens() {
        itens.clear();
        notifyDataSetChanged();
    }

    /**
     * Retorna a última mensagem (ignorando separadores)
     */
    private MensagemDTO getUltimaMensagem() {
        for (int i = itens.size() - 1; i >= 0; i--) {
            ItemChat item = itens.get(i);
            if (!item.isSeparadorData()) {
                return item.getMensagem();
            }
        }
        return null;
    }

    // ViewHolder para mensagens do paciente
    static class MensagemPacienteViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvMensagem;
        private final TextView tvHora;

        public MensagemPacienteViewHolder(@NonNull View itemView) {
            super(itemView);
            tvMensagem = itemView.findViewById(R.id.tvMensagem);
            tvHora = itemView.findViewById(R.id.tvHora);
        }

        public void bind(MensagemDTO mensagem) {
            tvMensagem.setText(mensagem.getMensagem());
            tvHora.setText(mensagem.getHoraFormatada());
        }
    }

    // ViewHolder para mensagens do funcionário
    static class MensagemFuncionarioViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvMensagem;
        private final TextView tvHora;

        public MensagemFuncionarioViewHolder(@NonNull View itemView) {
            super(itemView);
            tvMensagem = itemView.findViewById(R.id.tvMensagem);
            tvHora = itemView.findViewById(R.id.tvHora);
        }

        public void bind(MensagemDTO mensagem) {
            tvMensagem.setText(mensagem.getMensagem());
            tvHora.setText(mensagem.getHoraFormatada());
        }
    }

    // ViewHolder para separador de data
    static class SeparadorDataViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvData;

        public SeparadorDataViewHolder(@NonNull View itemView) {
            super(itemView);
            tvData = itemView.findViewById(R.id.tvData);
        }

        public void bind(String data) {
            tvData.setText(data);
        }
    }

    /**
     * Classe auxiliar para representar itens do RecyclerView
     * Pode ser uma mensagem ou um separador de data
     */
    private static class ItemChat {
        private final MensagemDTO mensagem;
        private final String dataSeparador;
        private final boolean isSeparadorData;

        // Construtor para mensagem
        public ItemChat(MensagemDTO mensagem) {
            this.mensagem = mensagem;
            this.dataSeparador = null;
            this.isSeparadorData = false;
        }

        // Construtor para separador de data
        public ItemChat(String dataSeparador) {
            this.mensagem = null;
            this.dataSeparador = dataSeparador;
            this.isSeparadorData = true;
        }

        public boolean isSeparadorData() {
            return isSeparadorData;
        }

        public MensagemDTO getMensagem() {
            return mensagem;
        }

        public String getDataSeparador() {
            return dataSeparador;
        }
    }
}

namespace Automácia
{
    partial class TelaReceita
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.PnlReceita = new System.Windows.Forms.Panel();
            this.PnlInformacoes = new System.Windows.Forms.Panel();
            this.LblExibirHorarioCriacao = new System.Windows.Forms.Label();
            this.LblHorarioDeCriacao = new System.Windows.Forms.Label();
            this.LblExibirDataCriacao = new System.Windows.Forms.Label();
            this.LblDataDeCriacao = new System.Windows.Forms.Label();
            this.LblExibirCPFPaciente = new System.Windows.Forms.Label();
            this.LblCPFPaciente = new System.Windows.Forms.Label();
            this.LblExibirLimiteBaixas = new System.Windows.Forms.Label();
            this.LblExibirBaixas = new System.Windows.Forms.Label();
            this.LblLimiteBaixas = new System.Windows.Forms.Label();
            this.LblBaixas = new System.Windows.Forms.Label();
            this.LblExibirDataValidade = new System.Windows.Forms.Label();
            this.LblDataDeValidade = new System.Windows.Forms.Label();
            this.LblExibirIDMedico = new System.Windows.Forms.Label();
            this.LblIDMedico = new System.Windows.Forms.Label();
            this.PnlPrescricao = new System.Windows.Forms.Panel();
            this.LblMedicamentos = new System.Windows.Forms.Label();
            this.LblUso = new System.Windows.Forms.Label();
            this.LblExibirNomeCompletoDoMedico = new System.Windows.Forms.Label();
            this.LblNomeCompletoDoMedico = new System.Windows.Forms.Label();
            this.LblReceita = new System.Windows.Forms.Label();
            this.PnlReceita.SuspendLayout();
            this.PnlInformacoes.SuspendLayout();
            this.PnlPrescricao.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlReceita
            // 
            this.PnlReceita.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlReceita.BackColor = System.Drawing.Color.White;
            this.PnlReceita.Controls.Add(this.PnlInformacoes);
            this.PnlReceita.Controls.Add(this.LblReceita);
            this.PnlReceita.Location = new System.Drawing.Point(16, 19);
            this.PnlReceita.Margin = new System.Windows.Forms.Padding(0);
            this.PnlReceita.Name = "PnlReceita";
            this.PnlReceita.Size = new System.Drawing.Size(500, 700);
            this.PnlReceita.TabIndex = 1;
            // 
            // PnlInformacoes
            // 
            this.PnlInformacoes.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlInformacoes.BackColor = System.Drawing.Color.Transparent;
            this.PnlInformacoes.Controls.Add(this.LblExibirHorarioCriacao);
            this.PnlInformacoes.Controls.Add(this.LblHorarioDeCriacao);
            this.PnlInformacoes.Controls.Add(this.LblExibirDataCriacao);
            this.PnlInformacoes.Controls.Add(this.LblDataDeCriacao);
            this.PnlInformacoes.Controls.Add(this.LblExibirCPFPaciente);
            this.PnlInformacoes.Controls.Add(this.LblCPFPaciente);
            this.PnlInformacoes.Controls.Add(this.LblExibirLimiteBaixas);
            this.PnlInformacoes.Controls.Add(this.LblExibirBaixas);
            this.PnlInformacoes.Controls.Add(this.LblLimiteBaixas);
            this.PnlInformacoes.Controls.Add(this.LblBaixas);
            this.PnlInformacoes.Controls.Add(this.LblExibirDataValidade);
            this.PnlInformacoes.Controls.Add(this.LblDataDeValidade);
            this.PnlInformacoes.Controls.Add(this.LblExibirIDMedico);
            this.PnlInformacoes.Controls.Add(this.LblIDMedico);
            this.PnlInformacoes.Controls.Add(this.PnlPrescricao);
            this.PnlInformacoes.Controls.Add(this.LblExibirNomeCompletoDoMedico);
            this.PnlInformacoes.Controls.Add(this.LblNomeCompletoDoMedico);
            this.PnlInformacoes.Location = new System.Drawing.Point(0, 60);
            this.PnlInformacoes.Margin = new System.Windows.Forms.Padding(0);
            this.PnlInformacoes.Name = "PnlInformacoes";
            this.PnlInformacoes.Size = new System.Drawing.Size(500, 640);
            this.PnlInformacoes.TabIndex = 1;
            // 
            // LblExibirHorarioCriacao
            // 
            this.LblExibirHorarioCriacao.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirHorarioCriacao.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirHorarioCriacao.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirHorarioCriacao.Location = new System.Drawing.Point(310, 590);
            this.LblExibirHorarioCriacao.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirHorarioCriacao.Name = "LblExibirHorarioCriacao";
            this.LblExibirHorarioCriacao.Size = new System.Drawing.Size(180, 33);
            this.LblExibirHorarioCriacao.TabIndex = 6;
            this.LblExibirHorarioCriacao.Text = "00:00:00";
            this.LblExibirHorarioCriacao.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblHorarioDeCriacao
            // 
            this.LblHorarioDeCriacao.BackColor = System.Drawing.Color.Transparent;
            this.LblHorarioDeCriacao.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblHorarioDeCriacao.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblHorarioDeCriacao.Location = new System.Drawing.Point(10, 590);
            this.LblHorarioDeCriacao.Margin = new System.Windows.Forms.Padding(0);
            this.LblHorarioDeCriacao.Name = "LblHorarioDeCriacao";
            this.LblHorarioDeCriacao.Size = new System.Drawing.Size(300, 33);
            this.LblHorarioDeCriacao.TabIndex = 7;
            this.LblHorarioDeCriacao.Text = "Horário da Criação:";
            this.LblHorarioDeCriacao.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirDataCriacao
            // 
            this.LblExibirDataCriacao.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirDataCriacao.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirDataCriacao.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirDataCriacao.Location = new System.Drawing.Point(275, 540);
            this.LblExibirDataCriacao.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirDataCriacao.Name = "LblExibirDataCriacao";
            this.LblExibirDataCriacao.Size = new System.Drawing.Size(215, 33);
            this.LblExibirDataCriacao.TabIndex = 4;
            this.LblExibirDataCriacao.Text = "00/00/0000";
            this.LblExibirDataCriacao.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblDataDeCriacao
            // 
            this.LblDataDeCriacao.BackColor = System.Drawing.Color.Transparent;
            this.LblDataDeCriacao.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDataDeCriacao.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblDataDeCriacao.Location = new System.Drawing.Point(10, 540);
            this.LblDataDeCriacao.Margin = new System.Windows.Forms.Padding(0);
            this.LblDataDeCriacao.Name = "LblDataDeCriacao";
            this.LblDataDeCriacao.Size = new System.Drawing.Size(267, 33);
            this.LblDataDeCriacao.TabIndex = 5;
            this.LblDataDeCriacao.Text = "Data de Criação:";
            this.LblDataDeCriacao.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirCPFPaciente
            // 
            this.LblExibirCPFPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirCPFPaciente.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirCPFPaciente.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirCPFPaciente.Location = new System.Drawing.Point(10, 43);
            this.LblExibirCPFPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirCPFPaciente.Name = "LblExibirCPFPaciente";
            this.LblExibirCPFPaciente.Size = new System.Drawing.Size(480, 33);
            this.LblExibirCPFPaciente.TabIndex = 3;
            this.LblExibirCPFPaciente.Text = "54856098802";
            this.LblExibirCPFPaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblCPFPaciente
            // 
            this.LblCPFPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblCPFPaciente.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblCPFPaciente.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblCPFPaciente.Location = new System.Drawing.Point(10, 10);
            this.LblCPFPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblCPFPaciente.Name = "LblCPFPaciente";
            this.LblCPFPaciente.Size = new System.Drawing.Size(480, 33);
            this.LblCPFPaciente.TabIndex = 2;
            this.LblCPFPaciente.Text = "CPF Paciente";
            this.LblCPFPaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirLimiteBaixas
            // 
            this.LblExibirLimiteBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirLimiteBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirLimiteBaixas.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirLimiteBaixas.Location = new System.Drawing.Point(216, 390);
            this.LblExibirLimiteBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirLimiteBaixas.Name = "LblExibirLimiteBaixas";
            this.LblExibirLimiteBaixas.Size = new System.Drawing.Size(275, 33);
            this.LblExibirLimiteBaixas.TabIndex = 0;
            this.LblExibirLimiteBaixas.Text = "10";
            this.LblExibirLimiteBaixas.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirBaixas
            // 
            this.LblExibirBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirBaixas.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirBaixas.Location = new System.Drawing.Point(173, 440);
            this.LblExibirBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirBaixas.Name = "LblExibirBaixas";
            this.LblExibirBaixas.Size = new System.Drawing.Size(317, 33);
            this.LblExibirBaixas.TabIndex = 0;
            this.LblExibirBaixas.Text = "10";
            this.LblExibirBaixas.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblLimiteBaixas
            // 
            this.LblLimiteBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblLimiteBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblLimiteBaixas.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblLimiteBaixas.Location = new System.Drawing.Point(10, 390);
            this.LblLimiteBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblLimiteBaixas.Name = "LblLimiteBaixas";
            this.LblLimiteBaixas.Size = new System.Drawing.Size(215, 33);
            this.LblLimiteBaixas.TabIndex = 0;
            this.LblLimiteBaixas.Text = "Limite Baixas:";
            this.LblLimiteBaixas.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblBaixas
            // 
            this.LblBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblBaixas.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblBaixas.Location = new System.Drawing.Point(10, 440);
            this.LblBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblBaixas.Name = "LblBaixas";
            this.LblBaixas.Size = new System.Drawing.Size(179, 33);
            this.LblBaixas.TabIndex = 0;
            this.LblBaixas.Text = "Nº Baixas:";
            this.LblBaixas.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirDataValidade
            // 
            this.LblExibirDataValidade.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirDataValidade.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirDataValidade.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirDataValidade.Location = new System.Drawing.Point(275, 490);
            this.LblExibirDataValidade.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirDataValidade.Name = "LblExibirDataValidade";
            this.LblExibirDataValidade.Size = new System.Drawing.Size(215, 33);
            this.LblExibirDataValidade.TabIndex = 0;
            this.LblExibirDataValidade.Text = "00/00/0000";
            this.LblExibirDataValidade.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblDataDeValidade
            // 
            this.LblDataDeValidade.BackColor = System.Drawing.Color.Transparent;
            this.LblDataDeValidade.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDataDeValidade.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblDataDeValidade.Location = new System.Drawing.Point(10, 490);
            this.LblDataDeValidade.Margin = new System.Windows.Forms.Padding(0);
            this.LblDataDeValidade.Name = "LblDataDeValidade";
            this.LblDataDeValidade.Size = new System.Drawing.Size(267, 33);
            this.LblDataDeValidade.TabIndex = 0;
            this.LblDataDeValidade.Text = "Data de Validade:";
            this.LblDataDeValidade.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirIDMedico
            // 
            this.LblExibirIDMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirIDMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirIDMedico.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirIDMedico.Location = new System.Drawing.Point(180, 340);
            this.LblExibirIDMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirIDMedico.Name = "LblExibirIDMedico";
            this.LblExibirIDMedico.Size = new System.Drawing.Size(311, 33);
            this.LblExibirIDMedico.TabIndex = 0;
            this.LblExibirIDMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblIDMedico
            // 
            this.LblIDMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblIDMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblIDMedico.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblIDMedico.Location = new System.Drawing.Point(10, 340);
            this.LblIDMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblIDMedico.Name = "LblIDMedico";
            this.LblIDMedico.Size = new System.Drawing.Size(171, 33);
            this.LblIDMedico.TabIndex = 0;
            this.LblIDMedico.Text = "ID Médico:";
            this.LblIDMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // PnlPrescricao
            // 
            this.PnlPrescricao.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.PnlPrescricao.BackColor = System.Drawing.Color.Transparent;
            this.PnlPrescricao.Controls.Add(this.LblMedicamentos);
            this.PnlPrescricao.Controls.Add(this.LblUso);
            this.PnlPrescricao.Location = new System.Drawing.Point(20, 182);
            this.PnlPrescricao.Margin = new System.Windows.Forms.Padding(0);
            this.PnlPrescricao.Name = "PnlPrescricao";
            this.PnlPrescricao.Size = new System.Drawing.Size(460, 135);
            this.PnlPrescricao.TabIndex = 0;
            this.PnlPrescricao.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlPrescricao_Paint);
            // 
            // LblMedicamentos
            // 
            this.LblMedicamentos.BackColor = System.Drawing.Color.Transparent;
            this.LblMedicamentos.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMedicamentos.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMedicamentos.Location = new System.Drawing.Point(1, 35);
            this.LblMedicamentos.Margin = new System.Windows.Forms.Padding(0);
            this.LblMedicamentos.Name = "LblMedicamentos";
            this.LblMedicamentos.Size = new System.Drawing.Size(458, 100);
            this.LblMedicamentos.TabIndex = 0;
            this.LblMedicamentos.Text = "Medicamento 1\r\nMedicamento 2\r\n";
            // 
            // LblUso
            // 
            this.LblUso.BackColor = System.Drawing.Color.Transparent;
            this.LblUso.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblUso.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblUso.Location = new System.Drawing.Point(1, 0);
            this.LblUso.Margin = new System.Windows.Forms.Padding(0);
            this.LblUso.Name = "LblUso";
            this.LblUso.Size = new System.Drawing.Size(458, 33);
            this.LblUso.TabIndex = 0;
            this.LblUso.Text = "Medicamento - Uso";
            this.LblUso.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirNomeCompletoDoMedico
            // 
            this.LblExibirNomeCompletoDoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirNomeCompletoDoMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirNomeCompletoDoMedico.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirNomeCompletoDoMedico.Location = new System.Drawing.Point(10, 128);
            this.LblExibirNomeCompletoDoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirNomeCompletoDoMedico.Name = "LblExibirNomeCompletoDoMedico";
            this.LblExibirNomeCompletoDoMedico.Size = new System.Drawing.Size(480, 33);
            this.LblExibirNomeCompletoDoMedico.TabIndex = 0;
            this.LblExibirNomeCompletoDoMedico.Text = "Nome Completo do Médico";
            this.LblExibirNomeCompletoDoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblNomeCompletoDoMedico
            // 
            this.LblNomeCompletoDoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblNomeCompletoDoMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblNomeCompletoDoMedico.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblNomeCompletoDoMedico.Location = new System.Drawing.Point(10, 95);
            this.LblNomeCompletoDoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblNomeCompletoDoMedico.Name = "LblNomeCompletoDoMedico";
            this.LblNomeCompletoDoMedico.Size = new System.Drawing.Size(480, 33);
            this.LblNomeCompletoDoMedico.TabIndex = 0;
            this.LblNomeCompletoDoMedico.Text = "Nome Completo do Medico";
            this.LblNomeCompletoDoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblReceita
            // 
            this.LblReceita.BackColor = System.Drawing.Color.Transparent;
            this.LblReceita.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblReceita.Font = new System.Drawing.Font("Arial", 16.5F, System.Drawing.FontStyle.Bold);
            this.LblReceita.Location = new System.Drawing.Point(0, 0);
            this.LblReceita.Margin = new System.Windows.Forms.Padding(0);
            this.LblReceita.Name = "LblReceita";
            this.LblReceita.Size = new System.Drawing.Size(500, 60);
            this.LblReceita.TabIndex = 0;
            this.LblReceita.Text = "Receita 0";
            this.LblReceita.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.LblReceita_Paint);
            // 
            // TelaReceita
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(532, 738);
            this.Controls.Add(this.PnlReceita);
            this.Name = "TelaReceita";
            this.Text = "TelaReceita";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaReceita_FormClosing);
            this.Load += new System.EventHandler(this.TelaReceita_Load);
            this.PnlReceita.ResumeLayout(false);
            this.PnlInformacoes.ResumeLayout(false);
            this.PnlPrescricao.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlReceita;
        private System.Windows.Forms.Panel PnlInformacoes;
        private System.Windows.Forms.Label LblExibirLimiteBaixas;
        private System.Windows.Forms.Label LblExibirBaixas;
        private System.Windows.Forms.Label LblLimiteBaixas;
        private System.Windows.Forms.Label LblBaixas;
        private System.Windows.Forms.Label LblExibirDataValidade;
        private System.Windows.Forms.Label LblDataDeValidade;
        private System.Windows.Forms.Label LblExibirIDMedico;
        private System.Windows.Forms.Label LblIDMedico;
        private System.Windows.Forms.Panel PnlPrescricao;
        private System.Windows.Forms.Label LblMedicamentos;
        private System.Windows.Forms.Label LblUso;
        private System.Windows.Forms.Label LblExibirNomeCompletoDoMedico;
        private System.Windows.Forms.Label LblNomeCompletoDoMedico;
        private System.Windows.Forms.Label LblReceita;
        private System.Windows.Forms.Label LblExibirCPFPaciente;
        private System.Windows.Forms.Label LblCPFPaciente;
        private System.Windows.Forms.Label LblExibirHorarioCriacao;
        private System.Windows.Forms.Label LblHorarioDeCriacao;
        private System.Windows.Forms.Label LblExibirDataCriacao;
        private System.Windows.Forms.Label LblDataDeCriacao;
    }
}
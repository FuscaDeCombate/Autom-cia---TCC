
namespace Automácia
{
    partial class TelaVerificarReceitaFuncFarmacia
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
            this.PnlVerificarReceita = new System.Windows.Forms.Panel();
            this.PnlResultadoVerificacao = new System.Windows.Forms.Panel();
            this.LblMotivoReceitaInvalida = new System.Windows.Forms.Label();
            this.LblReceitaInvalida = new System.Windows.Forms.Label();
            this.PnlInformacoes = new System.Windows.Forms.Panel();
            this.LblExibirDataValidade = new System.Windows.Forms.Label();
            this.LblDataDeValidade = new System.Windows.Forms.Label();
            this.LblExibirCRMMedico = new System.Windows.Forms.Label();
            this.LblExibirNomeCompletoMedico = new System.Windows.Forms.Label();
            this.LblInfoMedico = new System.Windows.Forms.Label();
            this.PnlPrescricao = new System.Windows.Forms.Panel();
            this.LblMedicamentos = new System.Windows.Forms.Label();
            this.LblUso = new System.Windows.Forms.Label();
            this.LblExibirNomeCompletoDoPaciente = new System.Windows.Forms.Label();
            this.LblNomeCompletoDoPaciente = new System.Windows.Forms.Label();
            this.PnlTxtBoxIDReceita = new System.Windows.Forms.Panel();
            this.TxtIDReceita = new System.Windows.Forms.TextBox();
            this.LblIDReceita = new System.Windows.Forms.Label();
            this.BtnPesquisar = new System.Windows.Forms.Button();
            this.LblVerificarReceita = new System.Windows.Forms.Label();
            this.PnlVerificarReceita.SuspendLayout();
            this.PnlResultadoVerificacao.SuspendLayout();
            this.PnlInformacoes.SuspendLayout();
            this.PnlPrescricao.SuspendLayout();
            this.PnlTxtBoxIDReceita.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlVerificarReceita
            // 
            this.PnlVerificarReceita.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlVerificarReceita.BackColor = System.Drawing.Color.White;
            this.PnlVerificarReceita.Controls.Add(this.PnlResultadoVerificacao);
            this.PnlVerificarReceita.Controls.Add(this.PnlInformacoes);
            this.PnlVerificarReceita.Controls.Add(this.PnlTxtBoxIDReceita);
            this.PnlVerificarReceita.Controls.Add(this.LblIDReceita);
            this.PnlVerificarReceita.Controls.Add(this.BtnPesquisar);
            this.PnlVerificarReceita.Controls.Add(this.LblVerificarReceita);
            this.PnlVerificarReceita.Location = new System.Drawing.Point(238, 35);
            this.PnlVerificarReceita.Margin = new System.Windows.Forms.Padding(0);
            this.PnlVerificarReceita.Name = "PnlVerificarReceita";
            this.PnlVerificarReceita.Size = new System.Drawing.Size(424, 530);
            this.PnlVerificarReceita.TabIndex = 14;
            this.PnlVerificarReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlVerificarReceita_Paint);
            // 
            // PnlResultadoVerificacao
            // 
            this.PnlResultadoVerificacao.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlResultadoVerificacao.BackColor = System.Drawing.Color.White;
            this.PnlResultadoVerificacao.Controls.Add(this.LblMotivoReceitaInvalida);
            this.PnlResultadoVerificacao.Controls.Add(this.LblReceitaInvalida);
            this.PnlResultadoVerificacao.Location = new System.Drawing.Point(22, 236);
            this.PnlResultadoVerificacao.Margin = new System.Windows.Forms.Padding(0);
            this.PnlResultadoVerificacao.Name = "PnlResultadoVerificacao";
            this.PnlResultadoVerificacao.Size = new System.Drawing.Size(380, 58);
            this.PnlResultadoVerificacao.TabIndex = 23;
            this.PnlResultadoVerificacao.Visible = false;
            // 
            // LblMotivoReceitaInvalida
            // 
            this.LblMotivoReceitaInvalida.BackColor = System.Drawing.Color.Transparent;
            this.LblMotivoReceitaInvalida.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMotivoReceitaInvalida.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMotivoReceitaInvalida.Location = new System.Drawing.Point(5, 29);
            this.LblMotivoReceitaInvalida.Margin = new System.Windows.Forms.Padding(0);
            this.LblMotivoReceitaInvalida.Name = "LblMotivoReceitaInvalida";
            this.LblMotivoReceitaInvalida.Size = new System.Drawing.Size(350, 27);
            this.LblMotivoReceitaInvalida.TabIndex = 23;
            this.LblMotivoReceitaInvalida.Text = "Receita expirada";
            this.LblMotivoReceitaInvalida.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // LblReceitaInvalida
            // 
            this.LblReceitaInvalida.BackColor = System.Drawing.Color.Transparent;
            this.LblReceitaInvalida.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblReceitaInvalida.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblReceitaInvalida.Location = new System.Drawing.Point(5, 2);
            this.LblReceitaInvalida.Margin = new System.Windows.Forms.Padding(0);
            this.LblReceitaInvalida.Name = "LblReceitaInvalida";
            this.LblReceitaInvalida.Size = new System.Drawing.Size(350, 27);
            this.LblReceitaInvalida.TabIndex = 22;
            this.LblReceitaInvalida.Text = "Receita Inválida";
            this.LblReceitaInvalida.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // PnlInformacoes
            // 
            this.PnlInformacoes.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlInformacoes.BackColor = System.Drawing.Color.Transparent;
            this.PnlInformacoes.Controls.Add(this.LblExibirDataValidade);
            this.PnlInformacoes.Controls.Add(this.LblDataDeValidade);
            this.PnlInformacoes.Controls.Add(this.LblExibirCRMMedico);
            this.PnlInformacoes.Controls.Add(this.LblExibirNomeCompletoMedico);
            this.PnlInformacoes.Controls.Add(this.LblInfoMedico);
            this.PnlInformacoes.Controls.Add(this.PnlPrescricao);
            this.PnlInformacoes.Controls.Add(this.LblExibirNomeCompletoDoPaciente);
            this.PnlInformacoes.Controls.Add(this.LblNomeCompletoDoPaciente);
            this.PnlInformacoes.Location = new System.Drawing.Point(22, 143);
            this.PnlInformacoes.Margin = new System.Windows.Forms.Padding(0);
            this.PnlInformacoes.Name = "PnlInformacoes";
            this.PnlInformacoes.Size = new System.Drawing.Size(380, 312);
            this.PnlInformacoes.TabIndex = 22;
            this.PnlInformacoes.Visible = false;
            // 
            // LblExibirDataValidade
            // 
            this.LblExibirDataValidade.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirDataValidade.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirDataValidade.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirDataValidade.Location = new System.Drawing.Point(216, 283);
            this.LblExibirDataValidade.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirDataValidade.Name = "LblExibirDataValidade";
            this.LblExibirDataValidade.Size = new System.Drawing.Size(156, 27);
            this.LblExibirDataValidade.TabIndex = 31;
            this.LblExibirDataValidade.Text = "00/00/0000";
            this.LblExibirDataValidade.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblDataDeValidade
            // 
            this.LblDataDeValidade.BackColor = System.Drawing.Color.Transparent;
            this.LblDataDeValidade.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDataDeValidade.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblDataDeValidade.Location = new System.Drawing.Point(5, 283);
            this.LblDataDeValidade.Margin = new System.Windows.Forms.Padding(0);
            this.LblDataDeValidade.Name = "LblDataDeValidade";
            this.LblDataDeValidade.Size = new System.Drawing.Size(200, 27);
            this.LblDataDeValidade.TabIndex = 30;
            this.LblDataDeValidade.Text = "Data de Validade:";
            this.LblDataDeValidade.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirCRMMedico
            // 
            this.LblExibirCRMMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirCRMMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirCRMMedico.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirCRMMedico.Location = new System.Drawing.Point(5, 243);
            this.LblExibirCRMMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirCRMMedico.Name = "LblExibirCRMMedico";
            this.LblExibirCRMMedico.Size = new System.Drawing.Size(370, 27);
            this.LblExibirCRMMedico.TabIndex = 29;
            this.LblExibirCRMMedico.Text = "CRM - ";
            this.LblExibirCRMMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirNomeCompletoMedico
            // 
            this.LblExibirNomeCompletoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirNomeCompletoMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirNomeCompletoMedico.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirNomeCompletoMedico.Location = new System.Drawing.Point(5, 215);
            this.LblExibirNomeCompletoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirNomeCompletoMedico.Name = "LblExibirNomeCompletoMedico";
            this.LblExibirNomeCompletoMedico.Size = new System.Drawing.Size(370, 27);
            this.LblExibirNomeCompletoMedico.TabIndex = 28;
            this.LblExibirNomeCompletoMedico.Text = "Nome Completo Médico";
            this.LblExibirNomeCompletoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblInfoMedico
            // 
            this.LblInfoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblInfoMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblInfoMedico.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblInfoMedico.Location = new System.Drawing.Point(6, 189);
            this.LblInfoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblInfoMedico.Name = "LblInfoMedico";
            this.LblInfoMedico.Size = new System.Drawing.Size(370, 27);
            this.LblInfoMedico.TabIndex = 27;
            this.LblInfoMedico.Text = "Informações do Médico";
            this.LblInfoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // PnlPrescricao
            // 
            this.PnlPrescricao.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlPrescricao.BackColor = System.Drawing.Color.Transparent;
            this.PnlPrescricao.Controls.Add(this.LblMedicamentos);
            this.PnlPrescricao.Controls.Add(this.LblUso);
            this.PnlPrescricao.Location = new System.Drawing.Point(9, 67);
            this.PnlPrescricao.Margin = new System.Windows.Forms.Padding(0);
            this.PnlPrescricao.Name = "PnlPrescricao";
            this.PnlPrescricao.Size = new System.Drawing.Size(361, 109);
            this.PnlPrescricao.TabIndex = 26;
            this.PnlPrescricao.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlPrescricao_Paint);
            // 
            // LblMedicamentos
            // 
            this.LblMedicamentos.BackColor = System.Drawing.Color.Transparent;
            this.LblMedicamentos.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMedicamentos.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMedicamentos.Location = new System.Drawing.Point(1, 28);
            this.LblMedicamentos.Margin = new System.Windows.Forms.Padding(0);
            this.LblMedicamentos.Name = "LblMedicamentos";
            this.LblMedicamentos.Size = new System.Drawing.Size(359, 81);
            this.LblMedicamentos.TabIndex = 28;
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
            this.LblUso.Size = new System.Drawing.Size(359, 27);
            this.LblUso.TabIndex = 27;
            this.LblUso.Text = "Uso";
            this.LblUso.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirNomeCompletoDoPaciente
            // 
            this.LblExibirNomeCompletoDoPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirNomeCompletoDoPaciente.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirNomeCompletoDoPaciente.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirNomeCompletoDoPaciente.Location = new System.Drawing.Point(4, 27);
            this.LblExibirNomeCompletoDoPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirNomeCompletoDoPaciente.Name = "LblExibirNomeCompletoDoPaciente";
            this.LblExibirNomeCompletoDoPaciente.Size = new System.Drawing.Size(370, 27);
            this.LblExibirNomeCompletoDoPaciente.TabIndex = 25;
            this.LblExibirNomeCompletoDoPaciente.Text = "Nome Completo do Paciente";
            this.LblExibirNomeCompletoDoPaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblNomeCompletoDoPaciente
            // 
            this.LblNomeCompletoDoPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblNomeCompletoDoPaciente.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblNomeCompletoDoPaciente.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblNomeCompletoDoPaciente.Location = new System.Drawing.Point(5, 0);
            this.LblNomeCompletoDoPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblNomeCompletoDoPaciente.Name = "LblNomeCompletoDoPaciente";
            this.LblNomeCompletoDoPaciente.Size = new System.Drawing.Size(370, 27);
            this.LblNomeCompletoDoPaciente.TabIndex = 24;
            this.LblNomeCompletoDoPaciente.Text = "Nome Completo do Paciente";
            this.LblNomeCompletoDoPaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // PnlTxtBoxIDReceita
            // 
            this.PnlTxtBoxIDReceita.Controls.Add(this.TxtIDReceita);
            this.PnlTxtBoxIDReceita.Location = new System.Drawing.Point(30, 103);
            this.PnlTxtBoxIDReceita.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxIDReceita.Name = "PnlTxtBoxIDReceita";
            this.PnlTxtBoxIDReceita.Size = new System.Drawing.Size(360, 27);
            this.PnlTxtBoxIDReceita.TabIndex = 20;
            this.PnlTxtBoxIDReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxIDReceita_Paint);
            // 
            // TxtIDReceita
            // 
            this.TxtIDReceita.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtIDReceita.Font = new System.Drawing.Font("Arial", 15F);
            this.TxtIDReceita.Location = new System.Drawing.Point(1, -2);
            this.TxtIDReceita.Margin = new System.Windows.Forms.Padding(0);
            this.TxtIDReceita.MaxLength = 12;
            this.TxtIDReceita.Name = "TxtIDReceita";
            this.TxtIDReceita.Size = new System.Drawing.Size(358, 23);
            this.TxtIDReceita.TabIndex = 16;
            // 
            // LblIDReceita
            // 
            this.LblIDReceita.BackColor = System.Drawing.Color.Transparent;
            this.LblIDReceita.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblIDReceita.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblIDReceita.Location = new System.Drawing.Point(25, 71);
            this.LblIDReceita.Margin = new System.Windows.Forms.Padding(0);
            this.LblIDReceita.Name = "LblIDReceita";
            this.LblIDReceita.Size = new System.Drawing.Size(370, 27);
            this.LblIDReceita.TabIndex = 14;
            this.LblIDReceita.Text = "ID Receita";
            this.LblIDReceita.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // BtnPesquisar
            // 
            this.BtnPesquisar.BackColor = System.Drawing.Color.White;
            this.BtnPesquisar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnPesquisar.FlatAppearance.BorderSize = 0;
            this.BtnPesquisar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnPesquisar.Font = new System.Drawing.Font("Arial", 16.5F);
            this.BtnPesquisar.Location = new System.Drawing.Point(119, 464);
            this.BtnPesquisar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnPesquisar.Name = "BtnPesquisar";
            this.BtnPesquisar.Size = new System.Drawing.Size(183, 51);
            this.BtnPesquisar.TabIndex = 13;
            this.BtnPesquisar.Text = "Pesquisar";
            this.BtnPesquisar.UseVisualStyleBackColor = false;
            this.BtnPesquisar.Click += new System.EventHandler(this.BtnPesquisar_Click);
            this.BtnPesquisar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnPesquisar_Paint);
            // 
            // LblVerificarReceita
            // 
            this.LblVerificarReceita.BackColor = System.Drawing.Color.Transparent;
            this.LblVerificarReceita.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblVerificarReceita.Font = new System.Drawing.Font("Arial", 16.5F, System.Drawing.FontStyle.Bold);
            this.LblVerificarReceita.Location = new System.Drawing.Point(2, 0);
            this.LblVerificarReceita.Margin = new System.Windows.Forms.Padding(0);
            this.LblVerificarReceita.Name = "LblVerificarReceita";
            this.LblVerificarReceita.Size = new System.Drawing.Size(420, 50);
            this.LblVerificarReceita.TabIndex = 12;
            this.LblVerificarReceita.Text = "Verificar Receita";
            this.LblVerificarReceita.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVerificarReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.LblVerificarReceita_Paint);
            // 
            // TelaVerificarReceitaFuncFarmacia
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlVerificarReceita);
            this.MinimumSize = new System.Drawing.Size(900, 599);
            this.Name = "TelaVerificarReceitaFuncFarmacia";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaVerificarReceita1FuncFarmacia";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaVerificarReceitaFuncFarmacia_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaVerificarReceitaFuncFarmacia_FormClosed);
            this.Load += new System.EventHandler(this.TelaVerificarReceitaFuncFarmacia_Load);
            this.PnlVerificarReceita.ResumeLayout(false);
            this.PnlResultadoVerificacao.ResumeLayout(false);
            this.PnlInformacoes.ResumeLayout(false);
            this.PnlPrescricao.ResumeLayout(false);
            this.PnlTxtBoxIDReceita.ResumeLayout(false);
            this.PnlTxtBoxIDReceita.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlVerificarReceita;
        private System.Windows.Forms.Panel PnlTxtBoxIDReceita;
        private System.Windows.Forms.TextBox TxtIDReceita;
        private System.Windows.Forms.Label LblIDReceita;
        private System.Windows.Forms.Button BtnPesquisar;
        private System.Windows.Forms.Label LblVerificarReceita;
        private System.Windows.Forms.Panel PnlResultadoVerificacao;
        private System.Windows.Forms.Label LblMotivoReceitaInvalida;
        private System.Windows.Forms.Label LblReceitaInvalida;
        private System.Windows.Forms.Panel PnlInformacoes;
        private System.Windows.Forms.Panel PnlPrescricao;
        private System.Windows.Forms.Label LblUso;
        private System.Windows.Forms.Label LblExibirNomeCompletoDoPaciente;
        private System.Windows.Forms.Label LblNomeCompletoDoPaciente;
        private System.Windows.Forms.Label LblMedicamentos;
        private System.Windows.Forms.Label LblExibirDataValidade;
        private System.Windows.Forms.Label LblDataDeValidade;
        private System.Windows.Forms.Label LblExibirCRMMedico;
        private System.Windows.Forms.Label LblExibirNomeCompletoMedico;
        private System.Windows.Forms.Label LblInfoMedico;
    }
}
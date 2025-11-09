
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
            this.BtnCancelar = new System.Windows.Forms.Button();
            this.PnlResultadoVerificacao = new System.Windows.Forms.Panel();
            this.LblMotivoReceitaInvalida = new System.Windows.Forms.Label();
            this.LblReceitaInvalida = new System.Windows.Forms.Label();
            this.PnlInformacoes = new System.Windows.Forms.Panel();
            this.LblSenha = new System.Windows.Forms.Label();
            this.PnlTxtBoxSenha = new System.Windows.Forms.Panel();
            this.TxtSenha = new System.Windows.Forms.TextBox();
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
            this.PnlTxtBoxCPFReceita = new System.Windows.Forms.Panel();
            this.TxtCPFReceita = new System.Windows.Forms.TextBox();
            this.LblCPFPaciente = new System.Windows.Forms.Label();
            this.BtnPesquisar = new System.Windows.Forms.Button();
            this.LblVerificarReceita = new System.Windows.Forms.Label();
            this.BtnProxima = new System.Windows.Forms.Button();
            this.BtnAnterior = new System.Windows.Forms.Button();
            this.PnlVerificarReceita.SuspendLayout();
            this.PnlResultadoVerificacao.SuspendLayout();
            this.PnlInformacoes.SuspendLayout();
            this.PnlTxtBoxSenha.SuspendLayout();
            this.PnlPrescricao.SuspendLayout();
            this.PnlTxtBoxCPFReceita.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlVerificarReceita
            // 
            this.PnlVerificarReceita.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlVerificarReceita.BackColor = System.Drawing.Color.White;
            this.PnlVerificarReceita.Controls.Add(this.BtnCancelar);
            this.PnlVerificarReceita.Controls.Add(this.PnlResultadoVerificacao);
            this.PnlVerificarReceita.Controls.Add(this.PnlInformacoes);
            this.PnlVerificarReceita.Controls.Add(this.PnlTxtBoxCPFReceita);
            this.PnlVerificarReceita.Controls.Add(this.LblCPFPaciente);
            this.PnlVerificarReceita.Controls.Add(this.BtnPesquisar);
            this.PnlVerificarReceita.Controls.Add(this.LblVerificarReceita);
            this.PnlVerificarReceita.Location = new System.Drawing.Point(317, 43);
            this.PnlVerificarReceita.Margin = new System.Windows.Forms.Padding(0);
            this.PnlVerificarReceita.Name = "PnlVerificarReceita";
            this.PnlVerificarReceita.Size = new System.Drawing.Size(565, 652);
            this.PnlVerificarReceita.TabIndex = 0;
            this.PnlVerificarReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlVerificarReceita_Paint);
            // 
            // BtnCancelar
            // 
            this.BtnCancelar.BackColor = System.Drawing.Color.White;
            this.BtnCancelar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.BtnCancelar.Enabled = false;
            this.BtnCancelar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnCancelar.FlatAppearance.BorderSize = 0;
            this.BtnCancelar.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(225)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.BtnCancelar.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Red;
            this.BtnCancelar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnCancelar.Font = new System.Drawing.Font("Arial", 16.5F);
            this.BtnCancelar.Location = new System.Drawing.Point(405, 570);
            this.BtnCancelar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnCancelar.Name = "BtnCancelar";
            this.BtnCancelar.Size = new System.Drawing.Size(59, 63);
            this.BtnCancelar.TabIndex = 3;
            this.BtnCancelar.Text = "X";
            this.BtnCancelar.UseVisualStyleBackColor = false;
            this.BtnCancelar.Visible = false;
            this.BtnCancelar.Click += new System.EventHandler(this.BtnCancelar_Click);
            this.BtnCancelar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnCancelar_Paint);
            this.BtnCancelar.MouseEnter += new System.EventHandler(this.BtnCancelar_MouseEnter);
            this.BtnCancelar.MouseLeave += new System.EventHandler(this.BtnCancelar_MouseLeave);
            // 
            // PnlResultadoVerificacao
            // 
            this.PnlResultadoVerificacao.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlResultadoVerificacao.BackColor = System.Drawing.Color.White;
            this.PnlResultadoVerificacao.Controls.Add(this.LblMotivoReceitaInvalida);
            this.PnlResultadoVerificacao.Controls.Add(this.LblReceitaInvalida);
            this.PnlResultadoVerificacao.Location = new System.Drawing.Point(29, 290);
            this.PnlResultadoVerificacao.Margin = new System.Windows.Forms.Padding(0);
            this.PnlResultadoVerificacao.Name = "PnlResultadoVerificacao";
            this.PnlResultadoVerificacao.Size = new System.Drawing.Size(507, 71);
            this.PnlResultadoVerificacao.TabIndex = 0;
            this.PnlResultadoVerificacao.Visible = false;
            // 
            // LblMotivoReceitaInvalida
            // 
            this.LblMotivoReceitaInvalida.BackColor = System.Drawing.Color.Transparent;
            this.LblMotivoReceitaInvalida.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMotivoReceitaInvalida.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMotivoReceitaInvalida.Location = new System.Drawing.Point(7, 36);
            this.LblMotivoReceitaInvalida.Margin = new System.Windows.Forms.Padding(0);
            this.LblMotivoReceitaInvalida.Name = "LblMotivoReceitaInvalida";
            this.LblMotivoReceitaInvalida.Size = new System.Drawing.Size(467, 33);
            this.LblMotivoReceitaInvalida.TabIndex = 0;
            this.LblMotivoReceitaInvalida.Text = "Receita expirada";
            this.LblMotivoReceitaInvalida.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // LblReceitaInvalida
            // 
            this.LblReceitaInvalida.BackColor = System.Drawing.Color.Transparent;
            this.LblReceitaInvalida.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblReceitaInvalida.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblReceitaInvalida.Location = new System.Drawing.Point(7, 2);
            this.LblReceitaInvalida.Margin = new System.Windows.Forms.Padding(0);
            this.LblReceitaInvalida.Name = "LblReceitaInvalida";
            this.LblReceitaInvalida.Size = new System.Drawing.Size(467, 33);
            this.LblReceitaInvalida.TabIndex = 0;
            this.LblReceitaInvalida.Text = "Receita Inválida";
            this.LblReceitaInvalida.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // PnlInformacoes
            // 
            this.PnlInformacoes.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlInformacoes.BackColor = System.Drawing.Color.Transparent;
            this.PnlInformacoes.Controls.Add(this.LblSenha);
            this.PnlInformacoes.Controls.Add(this.PnlTxtBoxSenha);
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
            this.PnlInformacoes.Location = new System.Drawing.Point(29, 154);
            this.PnlInformacoes.Margin = new System.Windows.Forms.Padding(0);
            this.PnlInformacoes.Name = "PnlInformacoes";
            this.PnlInformacoes.Size = new System.Drawing.Size(507, 416);
            this.PnlInformacoes.TabIndex = 1;
            this.PnlInformacoes.Visible = false;
            // 
            // LblSenha
            // 
            this.LblSenha.BackColor = System.Drawing.Color.Transparent;
            this.LblSenha.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblSenha.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblSenha.Location = new System.Drawing.Point(7, 369);
            this.LblSenha.Margin = new System.Windows.Forms.Padding(0);
            this.LblSenha.Name = "LblSenha";
            this.LblSenha.Size = new System.Drawing.Size(117, 33);
            this.LblSenha.TabIndex = 0;
            this.LblSenha.Text = "Senha:";
            this.LblSenha.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // PnlTxtBoxSenha
            // 
            this.PnlTxtBoxSenha.Controls.Add(this.TxtSenha);
            this.PnlTxtBoxSenha.Location = new System.Drawing.Point(125, 369);
            this.PnlTxtBoxSenha.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxSenha.Name = "PnlTxtBoxSenha";
            this.PnlTxtBoxSenha.Size = new System.Drawing.Size(371, 33);
            this.PnlTxtBoxSenha.TabIndex = 1;
            this.PnlTxtBoxSenha.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxSenha_Paint);
            // 
            // TxtSenha
            // 
            this.TxtSenha.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtSenha.Font = new System.Drawing.Font("Arial", 15F);
            this.TxtSenha.Location = new System.Drawing.Point(1, -2);
            this.TxtSenha.Margin = new System.Windows.Forms.Padding(0);
            this.TxtSenha.MaxLength = 256;
            this.TxtSenha.Name = "TxtSenha";
            this.TxtSenha.Size = new System.Drawing.Size(368, 29);
            this.TxtSenha.TabIndex = 1;
            this.TxtSenha.KeyDown += new System.Windows.Forms.KeyEventHandler(this.TxtSenha_KeyDown);
            // 
            // LblExibirLimiteBaixas
            // 
            this.LblExibirLimiteBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirLimiteBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirLimiteBaixas.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirLimiteBaixas.Location = new System.Drawing.Point(216, 258);
            this.LblExibirLimiteBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirLimiteBaixas.Name = "LblExibirLimiteBaixas";
            this.LblExibirLimiteBaixas.Size = new System.Drawing.Size(282, 33);
            this.LblExibirLimiteBaixas.TabIndex = 0;
            this.LblExibirLimiteBaixas.Text = "10";
            this.LblExibirLimiteBaixas.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirBaixas
            // 
            this.LblExibirBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirBaixas.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirBaixas.Location = new System.Drawing.Point(174, 295);
            this.LblExibirBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirBaixas.Name = "LblExibirBaixas";
            this.LblExibirBaixas.Size = new System.Drawing.Size(326, 33);
            this.LblExibirBaixas.TabIndex = 0;
            this.LblExibirBaixas.Text = "10";
            this.LblExibirBaixas.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblLimiteBaixas
            // 
            this.LblLimiteBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblLimiteBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblLimiteBaixas.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblLimiteBaixas.Location = new System.Drawing.Point(7, 258);
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
            this.LblBaixas.Location = new System.Drawing.Point(7, 295);
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
            this.LblExibirDataValidade.Location = new System.Drawing.Point(269, 332);
            this.LblExibirDataValidade.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirDataValidade.Name = "LblExibirDataValidade";
            this.LblExibirDataValidade.Size = new System.Drawing.Size(225, 33);
            this.LblExibirDataValidade.TabIndex = 0;
            this.LblExibirDataValidade.Text = "00/00/0000";
            this.LblExibirDataValidade.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblDataDeValidade
            // 
            this.LblDataDeValidade.BackColor = System.Drawing.Color.Transparent;
            this.LblDataDeValidade.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDataDeValidade.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblDataDeValidade.Location = new System.Drawing.Point(7, 332);
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
            this.LblExibirIDMedico.Location = new System.Drawing.Point(177, 222);
            this.LblExibirIDMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirIDMedico.Name = "LblExibirIDMedico";
            this.LblExibirIDMedico.Size = new System.Drawing.Size(321, 33);
            this.LblExibirIDMedico.TabIndex = 0;
            this.LblExibirIDMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblIDMedico
            // 
            this.LblIDMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblIDMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblIDMedico.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblIDMedico.Location = new System.Drawing.Point(7, 222);
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
            this.PnlPrescricao.Location = new System.Drawing.Point(12, 78);
            this.PnlPrescricao.Margin = new System.Windows.Forms.Padding(0);
            this.PnlPrescricao.Name = "PnlPrescricao";
            this.PnlPrescricao.Size = new System.Drawing.Size(481, 134);
            this.PnlPrescricao.TabIndex = 0;
            this.PnlPrescricao.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlPrescricao_Paint);
            // 
            // LblMedicamentos
            // 
            this.LblMedicamentos.BackColor = System.Drawing.Color.Transparent;
            this.LblMedicamentos.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMedicamentos.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMedicamentos.Location = new System.Drawing.Point(1, 34);
            this.LblMedicamentos.Margin = new System.Windows.Forms.Padding(0);
            this.LblMedicamentos.Name = "LblMedicamentos";
            this.LblMedicamentos.Size = new System.Drawing.Size(479, 100);
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
            this.LblUso.Size = new System.Drawing.Size(479, 33);
            this.LblUso.TabIndex = 0;
            this.LblUso.Text = "Medicamento - Uso";
            this.LblUso.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblExibirNomeCompletoDoMedico
            // 
            this.LblExibirNomeCompletoDoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblExibirNomeCompletoDoMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblExibirNomeCompletoDoMedico.Font = new System.Drawing.Font("Arial", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblExibirNomeCompletoDoMedico.Location = new System.Drawing.Point(5, 37);
            this.LblExibirNomeCompletoDoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblExibirNomeCompletoDoMedico.Name = "LblExibirNomeCompletoDoMedico";
            this.LblExibirNomeCompletoDoMedico.Size = new System.Drawing.Size(493, 33);
            this.LblExibirNomeCompletoDoMedico.TabIndex = 0;
            this.LblExibirNomeCompletoDoMedico.Text = "Nome Completo do Médico";
            this.LblExibirNomeCompletoDoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LblNomeCompletoDoMedico
            // 
            this.LblNomeCompletoDoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblNomeCompletoDoMedico.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblNomeCompletoDoMedico.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblNomeCompletoDoMedico.Location = new System.Drawing.Point(7, 4);
            this.LblNomeCompletoDoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.LblNomeCompletoDoMedico.Name = "LblNomeCompletoDoMedico";
            this.LblNomeCompletoDoMedico.Size = new System.Drawing.Size(493, 33);
            this.LblNomeCompletoDoMedico.TabIndex = 0;
            this.LblNomeCompletoDoMedico.Text = "Nome Completo do Médico";
            this.LblNomeCompletoDoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // PnlTxtBoxCPFReceita
            // 
            this.PnlTxtBoxCPFReceita.Controls.Add(this.TxtCPFReceita);
            this.PnlTxtBoxCPFReceita.Location = new System.Drawing.Point(40, 117);
            this.PnlTxtBoxCPFReceita.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxCPFReceita.Name = "PnlTxtBoxCPFReceita";
            this.PnlTxtBoxCPFReceita.Size = new System.Drawing.Size(480, 33);
            this.PnlTxtBoxCPFReceita.TabIndex = 0;
            this.PnlTxtBoxCPFReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxCPFReceita_Paint);
            // 
            // TxtCPFReceita
            // 
            this.TxtCPFReceita.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtCPFReceita.Font = new System.Drawing.Font("Arial", 15F);
            this.TxtCPFReceita.Location = new System.Drawing.Point(1, -2);
            this.TxtCPFReceita.Margin = new System.Windows.Forms.Padding(0);
            this.TxtCPFReceita.MaxLength = 11;
            this.TxtCPFReceita.Name = "TxtCPFReceita";
            this.TxtCPFReceita.Size = new System.Drawing.Size(477, 29);
            this.TxtCPFReceita.TabIndex = 1;
            this.TxtCPFReceita.KeyDown += new System.Windows.Forms.KeyEventHandler(this.TxtCPFReceita_KeyDown);
            this.TxtCPFReceita.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.Numerico_KeyPress);
            // 
            // LblCPFPaciente
            // 
            this.LblCPFPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblCPFPaciente.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblCPFPaciente.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblCPFPaciente.Location = new System.Drawing.Point(33, 78);
            this.LblCPFPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblCPFPaciente.Name = "LblCPFPaciente";
            this.LblCPFPaciente.Size = new System.Drawing.Size(493, 33);
            this.LblCPFPaciente.TabIndex = 0;
            this.LblCPFPaciente.Text = "CPF Paciente";
            this.LblCPFPaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // BtnPesquisar
            // 
            this.BtnPesquisar.BackColor = System.Drawing.Color.White;
            this.BtnPesquisar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.BtnPesquisar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnPesquisar.FlatAppearance.BorderSize = 0;
            this.BtnPesquisar.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(230)))), ((int)(((byte)(230)))));
            this.BtnPesquisar.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(205)))), ((int)(((byte)(205)))), ((int)(((byte)(205)))));
            this.BtnPesquisar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnPesquisar.Font = new System.Drawing.Font("Arial", 16.5F);
            this.BtnPesquisar.Location = new System.Drawing.Point(161, 570);
            this.BtnPesquisar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnPesquisar.Name = "BtnPesquisar";
            this.BtnPesquisar.Size = new System.Drawing.Size(244, 63);
            this.BtnPesquisar.TabIndex = 2;
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
            this.LblVerificarReceita.Location = new System.Drawing.Point(3, 0);
            this.LblVerificarReceita.Margin = new System.Windows.Forms.Padding(0);
            this.LblVerificarReceita.Name = "LblVerificarReceita";
            this.LblVerificarReceita.Size = new System.Drawing.Size(560, 62);
            this.LblVerificarReceita.TabIndex = 0;
            this.LblVerificarReceita.Text = "Verificar Receita";
            this.LblVerificarReceita.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVerificarReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.LblVerificarReceita_Paint);
            // 
            // BtnProxima
            // 
            this.BtnProxima.BackColor = System.Drawing.Color.White;
            this.BtnProxima.Cursor = System.Windows.Forms.Cursors.Hand;
            this.BtnProxima.Enabled = false;
            this.BtnProxima.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnProxima.FlatAppearance.BorderSize = 0;
            this.BtnProxima.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(230)))), ((int)(((byte)(230)))));
            this.BtnProxima.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(205)))), ((int)(((byte)(205)))), ((int)(((byte)(205)))));
            this.BtnProxima.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnProxima.Font = new System.Drawing.Font("Arial", 16.5F);
            this.BtnProxima.Location = new System.Drawing.Point(933, 338);
            this.BtnProxima.Margin = new System.Windows.Forms.Padding(0);
            this.BtnProxima.Name = "BtnProxima";
            this.BtnProxima.Size = new System.Drawing.Size(200, 63);
            this.BtnProxima.TabIndex = 2;
            this.BtnProxima.Text = "Próxima";
            this.BtnProxima.UseVisualStyleBackColor = false;
            this.BtnProxima.Visible = false;
            this.BtnProxima.Click += new System.EventHandler(this.BtnProxima_Click);
            this.BtnProxima.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnProxima_Paint);
            // 
            // BtnAnterior
            // 
            this.BtnAnterior.BackColor = System.Drawing.Color.White;
            this.BtnAnterior.Cursor = System.Windows.Forms.Cursors.Hand;
            this.BtnAnterior.Enabled = false;
            this.BtnAnterior.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnAnterior.FlatAppearance.BorderSize = 0;
            this.BtnAnterior.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(230)))), ((int)(((byte)(230)))));
            this.BtnAnterior.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(205)))), ((int)(((byte)(205)))), ((int)(((byte)(205)))));
            this.BtnAnterior.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnAnterior.Font = new System.Drawing.Font("Arial", 16.5F);
            this.BtnAnterior.Location = new System.Drawing.Point(67, 338);
            this.BtnAnterior.Margin = new System.Windows.Forms.Padding(0);
            this.BtnAnterior.Name = "BtnAnterior";
            this.BtnAnterior.Size = new System.Drawing.Size(200, 63);
            this.BtnAnterior.TabIndex = 1;
            this.BtnAnterior.Text = "Anterior";
            this.BtnAnterior.UseVisualStyleBackColor = false;
            this.BtnAnterior.Visible = false;
            this.BtnAnterior.Click += new System.EventHandler(this.BtnAnterior_Click);
            this.BtnAnterior.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnAnterior_Paint);
            // 
            // TelaVerificarReceitaFuncFarmacia
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(1200, 738);
            this.Controls.Add(this.BtnAnterior);
            this.Controls.Add(this.BtnProxima);
            this.Controls.Add(this.PnlVerificarReceita);
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MinimumSize = new System.Drawing.Size(1194, 723);
            this.Name = "TelaVerificarReceitaFuncFarmacia";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Farmacêutico - Automácia";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaVerificarReceitaFuncFarmacia_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaVerificarReceitaFuncFarmacia_FormClosed);
            this.Load += new System.EventHandler(this.TelaVerificarReceitaFuncFarmacia_Load);
            this.PnlVerificarReceita.ResumeLayout(false);
            this.PnlResultadoVerificacao.ResumeLayout(false);
            this.PnlInformacoes.ResumeLayout(false);
            this.PnlTxtBoxSenha.ResumeLayout(false);
            this.PnlTxtBoxSenha.PerformLayout();
            this.PnlPrescricao.ResumeLayout(false);
            this.PnlTxtBoxCPFReceita.ResumeLayout(false);
            this.PnlTxtBoxCPFReceita.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlVerificarReceita;
        private System.Windows.Forms.Panel PnlTxtBoxCPFReceita;
        private System.Windows.Forms.TextBox TxtCPFReceita;
        private System.Windows.Forms.Label LblCPFPaciente;
        private System.Windows.Forms.Button BtnPesquisar;
        private System.Windows.Forms.Label LblVerificarReceita;
        private System.Windows.Forms.Panel PnlResultadoVerificacao;
        private System.Windows.Forms.Label LblMotivoReceitaInvalida;
        private System.Windows.Forms.Label LblReceitaInvalida;
        private System.Windows.Forms.Panel PnlInformacoes;
        private System.Windows.Forms.Panel PnlPrescricao;
        private System.Windows.Forms.Label LblUso;
        private System.Windows.Forms.Label LblExibirNomeCompletoDoMedico;
        private System.Windows.Forms.Label LblNomeCompletoDoMedico;
        private System.Windows.Forms.Label LblMedicamentos;
        private System.Windows.Forms.Label LblExibirDataValidade;
        private System.Windows.Forms.Label LblDataDeValidade;
        private System.Windows.Forms.Label LblExibirIDMedico;
        private System.Windows.Forms.Label LblIDMedico;
        private System.Windows.Forms.Label LblLimiteBaixas;
        private System.Windows.Forms.Label LblBaixas;
        private System.Windows.Forms.Label LblExibirLimiteBaixas;
        private System.Windows.Forms.Label LblExibirBaixas;
        private System.Windows.Forms.Label LblSenha;
        private System.Windows.Forms.Panel PnlTxtBoxSenha;
        private System.Windows.Forms.TextBox TxtSenha;
        private System.Windows.Forms.Button BtnProxima;
        private System.Windows.Forms.Button BtnAnterior;
        private System.Windows.Forms.Button BtnCancelar;
    }
}
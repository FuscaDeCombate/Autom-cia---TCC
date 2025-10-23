
namespace Automácia
{
    partial class TelaFuncoesFuncHospital
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TelaFuncoesFuncHospital));
            this.PnlNavegacao = new System.Windows.Forms.Panel();
            this.BtnVerPacientes = new System.Windows.Forms.Button();
            this.BtnEmitirReceita = new System.Windows.Forms.Button();
            this.PnlFuncaoEmitirReceita = new System.Windows.Forms.Panel();
            this.LblLimiteBaixas = new System.Windows.Forms.Label();
            this.CmBoxLimitesBaixas = new System.Windows.Forms.ComboBox();
            this.DataValidade = new System.Windows.Forms.DateTimePicker();
            this.PnlTxtBoxDetalhes = new System.Windows.Forms.Panel();
            this.LblDataValidade = new System.Windows.Forms.Label();
            this.PnlTxtBoxSenha = new System.Windows.Forms.Panel();
            this.TxtSenha = new System.Windows.Forms.TextBox();
            this.LblDetalhes = new System.Windows.Forms.Label();
            this.LblSenha = new System.Windows.Forms.Label();
            this.PnlTxtBoxCPF = new System.Windows.Forms.Panel();
            this.TxtCPFPaciente = new System.Windows.Forms.TextBox();
            this.PnlTxtBoxMedicamento = new System.Windows.Forms.Panel();
            this.TxtMedicamento = new System.Windows.Forms.TextBox();
            this.LblMedicamento = new System.Windows.Forms.Label();
            this.LblCPFPaciente = new System.Windows.Forms.Label();
            this.BtnEmitir = new System.Windows.Forms.Button();
            this.PnlFuncoes = new System.Windows.Forms.Panel();
            this.PnlFuncaoVerPacientes = new System.Windows.Forms.Panel();
            this.PnlConteudoVer = new System.Windows.Forms.Panel();
            this.PnlPesquisarCPF = new System.Windows.Forms.Panel();
            this.PnlTxtBoxPesquisarCPF = new System.Windows.Forms.Panel();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.TxtPesquisarCPF = new System.Windows.Forms.TextBox();
            this.PnlPerfilPaciente = new System.Windows.Forms.Panel();
            this.LblVerCPFPaciente = new System.Windows.Forms.Label();
            this.LblVerCPF = new System.Windows.Forms.Label();
            this.LblVerNomePaciente = new System.Windows.Forms.Label();
            this.LblVerNome = new System.Windows.Forms.Label();
            this.PicBoxFotoPerfil = new System.Windows.Forms.PictureBox();
            this.PnlHistoricoMedico = new System.Windows.Forms.Panel();
            this.PicBoxHistoricoMedico = new System.Windows.Forms.PictureBox();
            this.LblHistoricoMedico = new System.Windows.Forms.Label();
            this.PnlVerPacientes = new System.Windows.Forms.Panel();
            this.PnlNavegacao.SuspendLayout();
            this.PnlFuncaoEmitirReceita.SuspendLayout();
            this.PnlTxtBoxSenha.SuspendLayout();
            this.PnlTxtBoxCPF.SuspendLayout();
            this.PnlTxtBoxMedicamento.SuspendLayout();
            this.PnlFuncoes.SuspendLayout();
            this.PnlFuncaoVerPacientes.SuspendLayout();
            this.PnlConteudoVer.SuspendLayout();
            this.PnlPesquisarCPF.SuspendLayout();
            this.PnlTxtBoxPesquisarCPF.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.PnlPerfilPaciente.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxFotoPerfil)).BeginInit();
            this.PnlHistoricoMedico.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxHistoricoMedico)).BeginInit();
            this.SuspendLayout();
            // 
            // PnlNavegacao
            // 
            this.PnlNavegacao.BackColor = System.Drawing.Color.Black;
            this.PnlNavegacao.Controls.Add(this.BtnVerPacientes);
            this.PnlNavegacao.Controls.Add(this.BtnEmitirReceita);
            this.PnlNavegacao.Location = new System.Drawing.Point(-1, 0);
            this.PnlNavegacao.Margin = new System.Windows.Forms.Padding(0);
            this.PnlNavegacao.Name = "PnlNavegacao";
            this.PnlNavegacao.Size = new System.Drawing.Size(827, 48);
            this.PnlNavegacao.TabIndex = 0;
            this.PnlNavegacao.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlNavegacao_Paint);
            // 
            // BtnVerPacientes
            // 
            this.BtnVerPacientes.BackColor = System.Drawing.Color.White;
            this.BtnVerPacientes.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnVerPacientes.FlatAppearance.BorderSize = 0;
            this.BtnVerPacientes.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnVerPacientes.Font = new System.Drawing.Font("Arial", 16.55F, System.Drawing.FontStyle.Bold);
            this.BtnVerPacientes.ForeColor = System.Drawing.Color.Gray;
            this.BtnVerPacientes.Location = new System.Drawing.Point(3, 2);
            this.BtnVerPacientes.Margin = new System.Windows.Forms.Padding(0);
            this.BtnVerPacientes.Name = "BtnVerPacientes";
            this.BtnVerPacientes.Size = new System.Drawing.Size(409, 44);
            this.BtnVerPacientes.TabIndex = 1;
            this.BtnVerPacientes.Text = "Chat dos Pacientes";
            this.BtnVerPacientes.UseVisualStyleBackColor = false;
            this.BtnVerPacientes.Click += new System.EventHandler(this.BtnVerPacientes_Click);
            this.BtnVerPacientes.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnVerPacientes_Paint);
            // 
            // BtnEmitirReceita
            // 
            this.BtnEmitirReceita.BackColor = System.Drawing.Color.White;
            this.BtnEmitirReceita.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnEmitirReceita.FlatAppearance.BorderSize = 0;
            this.BtnEmitirReceita.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnEmitirReceita.Font = new System.Drawing.Font("Arial", 16.55F, System.Drawing.FontStyle.Bold);
            this.BtnEmitirReceita.ForeColor = System.Drawing.Color.Gray;
            this.BtnEmitirReceita.Location = new System.Drawing.Point(415, 2);
            this.BtnEmitirReceita.Margin = new System.Windows.Forms.Padding(0);
            this.BtnEmitirReceita.Name = "BtnEmitirReceita";
            this.BtnEmitirReceita.Size = new System.Drawing.Size(409, 44);
            this.BtnEmitirReceita.TabIndex = 1;
            this.BtnEmitirReceita.Text = " Emitir receita";
            this.BtnEmitirReceita.UseVisualStyleBackColor = false;
            this.BtnEmitirReceita.Click += new System.EventHandler(this.BtnEmitirReceita_Click);
            this.BtnEmitirReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnEmitirReceita_Paint);
            // 
            // PnlFuncaoEmitirReceita
            // 
            this.PnlFuncaoEmitirReceita.BackColor = System.Drawing.Color.White;
            this.PnlFuncaoEmitirReceita.Controls.Add(this.LblLimiteBaixas);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.CmBoxLimitesBaixas);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.DataValidade);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.PnlTxtBoxDetalhes);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.LblDataValidade);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.PnlTxtBoxSenha);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.LblDetalhes);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.LblSenha);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.PnlTxtBoxCPF);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.PnlTxtBoxMedicamento);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.LblMedicamento);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.LblCPFPaciente);
            this.PnlFuncaoEmitirReceita.Controls.Add(this.BtnEmitir);
            this.PnlFuncaoEmitirReceita.Location = new System.Drawing.Point(0, 48);
            this.PnlFuncaoEmitirReceita.Margin = new System.Windows.Forms.Padding(0);
            this.PnlFuncaoEmitirReceita.Name = "PnlFuncaoEmitirReceita";
            this.PnlFuncaoEmitirReceita.Size = new System.Drawing.Size(825, 479);
            this.PnlFuncaoEmitirReceita.TabIndex = 1;
            this.PnlFuncaoEmitirReceita.Visible = false;
            this.PnlFuncaoEmitirReceita.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlFuncaoEmitirReceita_Paint);
            // 
            // LblLimiteBaixas
            // 
            this.LblLimiteBaixas.BackColor = System.Drawing.Color.Transparent;
            this.LblLimiteBaixas.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblLimiteBaixas.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblLimiteBaixas.Location = new System.Drawing.Point(510, 106);
            this.LblLimiteBaixas.Margin = new System.Windows.Forms.Padding(0);
            this.LblLimiteBaixas.Name = "LblLimiteBaixas";
            this.LblLimiteBaixas.Size = new System.Drawing.Size(155, 27);
            this.LblLimiteBaixas.TabIndex = 0;
            this.LblLimiteBaixas.Text = "Limite de baixas";
            // 
            // CmBoxLimitesBaixas
            // 
            this.CmBoxLimitesBaixas.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.CmBoxLimitesBaixas.Font = new System.Drawing.Font("Arial Narrow", 19.8F);
            this.CmBoxLimitesBaixas.FormattingEnabled = true;
            this.CmBoxLimitesBaixas.Items.AddRange(new object[] {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10"});
            this.CmBoxLimitesBaixas.Location = new System.Drawing.Point(512, 136);
            this.CmBoxLimitesBaixas.Name = "CmBoxLimitesBaixas";
            this.CmBoxLimitesBaixas.Size = new System.Drawing.Size(150, 39);
            this.CmBoxLimitesBaixas.TabIndex = 3;
            this.CmBoxLimitesBaixas.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            this.CmBoxLimitesBaixas.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.Proibir_KeyPress);
            // 
            // DataValidade
            // 
            this.DataValidade.CustomFormat = "dd/MM/yyyy";
            this.DataValidade.Font = new System.Drawing.Font("Arial", 18.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.DataValidade.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.DataValidade.Location = new System.Drawing.Point(471, 49);
            this.DataValidade.Margin = new System.Windows.Forms.Padding(0);
            this.DataValidade.Name = "DataValidade";
            this.DataValidade.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
            this.DataValidade.Size = new System.Drawing.Size(190, 36);
            this.DataValidade.TabIndex = 1;
            this.DataValidade.Value = new System.DateTime(2025, 10, 20, 0, 0, 0, 0);
            this.DataValidade.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            // 
            // PnlTxtBoxDetalhes
            // 
            this.PnlTxtBoxDetalhes.BackColor = System.Drawing.Color.White;
            this.PnlTxtBoxDetalhes.ForeColor = System.Drawing.Color.Transparent;
            this.PnlTxtBoxDetalhes.Location = new System.Drawing.Point(162, 315);
            this.PnlTxtBoxDetalhes.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxDetalhes.Name = "PnlTxtBoxDetalhes";
            this.PnlTxtBoxDetalhes.Size = new System.Drawing.Size(500, 70);
            this.PnlTxtBoxDetalhes.TabIndex = 5;
            this.PnlTxtBoxDetalhes.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxDetalhes_Paint);
            // 
            // LblDataValidade
            // 
            this.LblDataValidade.BackColor = System.Drawing.Color.Transparent;
            this.LblDataValidade.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDataValidade.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblDataValidade.Location = new System.Drawing.Point(468, 19);
            this.LblDataValidade.Margin = new System.Windows.Forms.Padding(0);
            this.LblDataValidade.Name = "LblDataValidade";
            this.LblDataValidade.Size = new System.Drawing.Size(195, 27);
            this.LblDataValidade.TabIndex = 0;
            this.LblDataValidade.Text = "Data Validade";
            // 
            // PnlTxtBoxSenha
            // 
            this.PnlTxtBoxSenha.Controls.Add(this.TxtSenha);
            this.PnlTxtBoxSenha.Location = new System.Drawing.Point(162, 138);
            this.PnlTxtBoxSenha.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxSenha.Name = "PnlTxtBoxSenha";
            this.PnlTxtBoxSenha.Size = new System.Drawing.Size(330, 37);
            this.PnlTxtBoxSenha.TabIndex = 2;
            this.PnlTxtBoxSenha.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxSenha_Paint);
            // 
            // TxtSenha
            // 
            this.TxtSenha.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtSenha.Font = new System.Drawing.Font("Arial", 20F);
            this.TxtSenha.Location = new System.Drawing.Point(1, 0);
            this.TxtSenha.Margin = new System.Windows.Forms.Padding(0);
            this.TxtSenha.MaxLength = 32;
            this.TxtSenha.Name = "TxtSenha";
            this.TxtSenha.Size = new System.Drawing.Size(328, 31);
            this.TxtSenha.TabIndex = 0;
            this.TxtSenha.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            // 
            // LblDetalhes
            // 
            this.LblDetalhes.BackColor = System.Drawing.Color.Transparent;
            this.LblDetalhes.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDetalhes.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblDetalhes.Location = new System.Drawing.Point(160, 284);
            this.LblDetalhes.Margin = new System.Windows.Forms.Padding(0);
            this.LblDetalhes.Name = "LblDetalhes";
            this.LblDetalhes.Size = new System.Drawing.Size(505, 27);
            this.LblDetalhes.TabIndex = 0;
            this.LblDetalhes.Text = "Detalhes";
            // 
            // LblSenha
            // 
            this.LblSenha.BackColor = System.Drawing.Color.Transparent;
            this.LblSenha.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblSenha.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblSenha.Location = new System.Drawing.Point(160, 107);
            this.LblSenha.Margin = new System.Windows.Forms.Padding(0);
            this.LblSenha.Name = "LblSenha";
            this.LblSenha.Size = new System.Drawing.Size(335, 27);
            this.LblSenha.TabIndex = 0;
            this.LblSenha.Text = "Senha";
            // 
            // PnlTxtBoxCPF
            // 
            this.PnlTxtBoxCPF.Controls.Add(this.TxtCPFPaciente);
            this.PnlTxtBoxCPF.Location = new System.Drawing.Point(162, 50);
            this.PnlTxtBoxCPF.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxCPF.Name = "PnlTxtBoxCPF";
            this.PnlTxtBoxCPF.Size = new System.Drawing.Size(290, 37);
            this.PnlTxtBoxCPF.TabIndex = 0;
            this.PnlTxtBoxCPF.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxCPF_Paint);
            // 
            // TxtCPFPaciente
            // 
            this.TxtCPFPaciente.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtCPFPaciente.Font = new System.Drawing.Font("Arial", 20F);
            this.TxtCPFPaciente.Location = new System.Drawing.Point(1, 0);
            this.TxtCPFPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.TxtCPFPaciente.MaxLength = 11;
            this.TxtCPFPaciente.Name = "TxtCPFPaciente";
            this.TxtCPFPaciente.Size = new System.Drawing.Size(288, 31);
            this.TxtCPFPaciente.TabIndex = 0;
            this.TxtCPFPaciente.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            this.TxtCPFPaciente.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.Numerico_KeyPress);
            // 
            // PnlTxtBoxMedicamento
            // 
            this.PnlTxtBoxMedicamento.Controls.Add(this.TxtMedicamento);
            this.PnlTxtBoxMedicamento.Location = new System.Drawing.Point(162, 226);
            this.PnlTxtBoxMedicamento.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxMedicamento.Name = "PnlTxtBoxMedicamento";
            this.PnlTxtBoxMedicamento.Size = new System.Drawing.Size(500, 37);
            this.PnlTxtBoxMedicamento.TabIndex = 4;
            this.PnlTxtBoxMedicamento.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxMedicamento_Paint);
            // 
            // TxtMedicamento
            // 
            this.TxtMedicamento.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtMedicamento.Font = new System.Drawing.Font("Arial", 20F);
            this.TxtMedicamento.Location = new System.Drawing.Point(1, 0);
            this.TxtMedicamento.Margin = new System.Windows.Forms.Padding(0);
            this.TxtMedicamento.MaxLength = 1000;
            this.TxtMedicamento.Name = "TxtMedicamento";
            this.TxtMedicamento.Size = new System.Drawing.Size(498, 31);
            this.TxtMedicamento.TabIndex = 0;
            this.TxtMedicamento.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            // 
            // LblMedicamento
            // 
            this.LblMedicamento.BackColor = System.Drawing.Color.Transparent;
            this.LblMedicamento.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMedicamento.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMedicamento.Location = new System.Drawing.Point(160, 196);
            this.LblMedicamento.Margin = new System.Windows.Forms.Padding(0);
            this.LblMedicamento.Name = "LblMedicamento";
            this.LblMedicamento.Size = new System.Drawing.Size(505, 27);
            this.LblMedicamento.TabIndex = 0;
            this.LblMedicamento.Text = "Medicamento";
            // 
            // LblCPFPaciente
            // 
            this.LblCPFPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblCPFPaciente.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblCPFPaciente.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblCPFPaciente.Location = new System.Drawing.Point(160, 20);
            this.LblCPFPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblCPFPaciente.Name = "LblCPFPaciente";
            this.LblCPFPaciente.Size = new System.Drawing.Size(295, 27);
            this.LblCPFPaciente.TabIndex = 0;
            this.LblCPFPaciente.Text = "CPF do Paciente";
            // 
            // BtnEmitir
            // 
            this.BtnEmitir.BackColor = System.Drawing.Color.White;
            this.BtnEmitir.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnEmitir.FlatAppearance.BorderSize = 0;
            this.BtnEmitir.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnEmitir.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnEmitir.Location = new System.Drawing.Point(300, 400);
            this.BtnEmitir.Margin = new System.Windows.Forms.Padding(0);
            this.BtnEmitir.Name = "BtnEmitir";
            this.BtnEmitir.Size = new System.Drawing.Size(225, 60);
            this.BtnEmitir.TabIndex = 6;
            this.BtnEmitir.Text = "Emitir";
            this.BtnEmitir.UseVisualStyleBackColor = false;
            this.BtnEmitir.Click += new System.EventHandler(this.BtnEmitir_Click);
            this.BtnEmitir.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnEmitir_Paint);
            this.BtnEmitir.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            // 
            // PnlFuncoes
            // 
            this.PnlFuncoes.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlFuncoes.BackColor = System.Drawing.Color.White;
            this.PnlFuncoes.Controls.Add(this.PnlFuncaoEmitirReceita);
            this.PnlFuncoes.Controls.Add(this.PnlFuncaoVerPacientes);
            this.PnlFuncoes.Controls.Add(this.PnlNavegacao);
            this.PnlFuncoes.Location = new System.Drawing.Point(38, 37);
            this.PnlFuncoes.Name = "PnlFuncoes";
            this.PnlFuncoes.Size = new System.Drawing.Size(825, 527);
            this.PnlFuncoes.TabIndex = 0;
            // 
            // PnlFuncaoVerPacientes
            // 
            this.PnlFuncaoVerPacientes.BackColor = System.Drawing.Color.White;
            this.PnlFuncaoVerPacientes.Controls.Add(this.PnlConteudoVer);
            this.PnlFuncaoVerPacientes.Location = new System.Drawing.Point(0, 48);
            this.PnlFuncaoVerPacientes.Margin = new System.Windows.Forms.Padding(0);
            this.PnlFuncaoVerPacientes.Name = "PnlFuncaoVerPacientes";
            this.PnlFuncaoVerPacientes.Size = new System.Drawing.Size(825, 479);
            this.PnlFuncaoVerPacientes.TabIndex = 1;
            this.PnlFuncaoVerPacientes.Visible = false;
            this.PnlFuncaoVerPacientes.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlFuncaoVerPacientes_Paint);
            // 
            // PnlConteudoVer
            // 
            this.PnlConteudoVer.BackColor = System.Drawing.Color.White;
            this.PnlConteudoVer.Controls.Add(this.PnlPesquisarCPF);
            this.PnlConteudoVer.Controls.Add(this.PnlPerfilPaciente);
            this.PnlConteudoVer.Controls.Add(this.PnlHistoricoMedico);
            this.PnlConteudoVer.Controls.Add(this.PnlVerPacientes);
            this.PnlConteudoVer.Location = new System.Drawing.Point(12, 8);
            this.PnlConteudoVer.Margin = new System.Windows.Forms.Padding(0);
            this.PnlConteudoVer.Name = "PnlConteudoVer";
            this.PnlConteudoVer.Size = new System.Drawing.Size(801, 459);
            this.PnlConteudoVer.TabIndex = 0;
            this.PnlConteudoVer.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlConteudoVer_Paint);
            // 
            // PnlPesquisarCPF
            // 
            this.PnlPesquisarCPF.BackColor = System.Drawing.Color.Transparent;
            this.PnlPesquisarCPF.Controls.Add(this.PnlTxtBoxPesquisarCPF);
            this.PnlPesquisarCPF.Location = new System.Drawing.Point(0, 0);
            this.PnlPesquisarCPF.Margin = new System.Windows.Forms.Padding(0);
            this.PnlPesquisarCPF.Name = "PnlPesquisarCPF";
            this.PnlPesquisarCPF.Size = new System.Drawing.Size(799, 46);
            this.PnlPesquisarCPF.TabIndex = 0;
            this.PnlPesquisarCPF.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlPesquisarNome_Paint);
            // 
            // PnlTxtBoxPesquisarCPF
            // 
            this.PnlTxtBoxPesquisarCPF.Controls.Add(this.pictureBox1);
            this.PnlTxtBoxPesquisarCPF.Controls.Add(this.TxtPesquisarCPF);
            this.PnlTxtBoxPesquisarCPF.Location = new System.Drawing.Point(8, 6);
            this.PnlTxtBoxPesquisarCPF.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxPesquisarCPF.Name = "PnlTxtBoxPesquisarCPF";
            this.PnlTxtBoxPesquisarCPF.Size = new System.Drawing.Size(783, 36);
            this.PnlTxtBoxPesquisarCPF.TabIndex = 0;
            this.PnlTxtBoxPesquisarCPF.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxPesquisarNome_Paint);
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackColor = System.Drawing.Color.Transparent;
            this.pictureBox1.Image = ((System.Drawing.Image)(resources.GetObject("pictureBox1.Image")));
            this.pictureBox1.Location = new System.Drawing.Point(12, 6);
            this.pictureBox1.Margin = new System.Windows.Forms.Padding(0);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(24, 24);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 3;
            this.pictureBox1.TabStop = false;
            // 
            // TxtPesquisarCPF
            // 
            this.TxtPesquisarCPF.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtPesquisarCPF.Font = new System.Drawing.Font("Arial", 15.5F);
            this.TxtPesquisarCPF.Location = new System.Drawing.Point(46, 5);
            this.TxtPesquisarCPF.Margin = new System.Windows.Forms.Padding(0);
            this.TxtPesquisarCPF.MaxLength = 1000;
            this.TxtPesquisarCPF.Name = "TxtPesquisarCPF";
            this.TxtPesquisarCPF.Size = new System.Drawing.Size(725, 24);
            this.TxtPesquisarCPF.TabIndex = 0;
            this.TxtPesquisarCPF.Enter += new System.EventHandler(this.TxtPesquisarNome_Enter);
            this.TxtPesquisarCPF.KeyDown += new System.Windows.Forms.KeyEventHandler(this.TxtPesquisarCPF_KeyDown);
            this.TxtPesquisarCPF.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.Numerico_KeyPress);
            this.TxtPesquisarCPF.Leave += new System.EventHandler(this.TxtPesquisarNome_Leave);
            // 
            // PnlPerfilPaciente
            // 
            this.PnlPerfilPaciente.BackColor = System.Drawing.Color.Transparent;
            this.PnlPerfilPaciente.Controls.Add(this.LblVerCPFPaciente);
            this.PnlPerfilPaciente.Controls.Add(this.LblVerCPF);
            this.PnlPerfilPaciente.Controls.Add(this.LblVerNomePaciente);
            this.PnlPerfilPaciente.Controls.Add(this.LblVerNome);
            this.PnlPerfilPaciente.Controls.Add(this.PicBoxFotoPerfil);
            this.PnlPerfilPaciente.Location = new System.Drawing.Point(497, 46);
            this.PnlPerfilPaciente.Margin = new System.Windows.Forms.Padding(0);
            this.PnlPerfilPaciente.Name = "PnlPerfilPaciente";
            this.PnlPerfilPaciente.Size = new System.Drawing.Size(302, 413);
            this.PnlPerfilPaciente.TabIndex = 0;
            this.PnlPerfilPaciente.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlPerfilPaciente_Paint);
            // 
            // LblVerCPFPaciente
            // 
            this.LblVerCPFPaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblVerCPFPaciente.Font = new System.Drawing.Font("Arial", 15F);
            this.LblVerCPFPaciente.Location = new System.Drawing.Point(104, 304);
            this.LblVerCPFPaciente.Name = "LblVerCPFPaciente";
            this.LblVerCPFPaciente.Size = new System.Drawing.Size(178, 24);
            this.LblVerCPFPaciente.TabIndex = 0;
            this.LblVerCPFPaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.LblVerCPFPaciente.Visible = false;
            // 
            // LblVerCPF
            // 
            this.LblVerCPF.BackColor = System.Drawing.Color.Transparent;
            this.LblVerCPF.Font = new System.Drawing.Font("Arial", 16.5F, System.Drawing.FontStyle.Bold);
            this.LblVerCPF.Location = new System.Drawing.Point(24, 304);
            this.LblVerCPF.Margin = new System.Windows.Forms.Padding(0);
            this.LblVerCPF.Name = "LblVerCPF";
            this.LblVerCPF.Size = new System.Drawing.Size(85, 24);
            this.LblVerCPF.TabIndex = 0;
            this.LblVerCPF.Text = "CPF:";
            this.LblVerCPF.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.LblVerCPF.Visible = false;
            // 
            // LblVerNomePaciente
            // 
            this.LblVerNomePaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblVerNomePaciente.Font = new System.Drawing.Font("Arial", 15F);
            this.LblVerNomePaciente.Location = new System.Drawing.Point(104, 271);
            this.LblVerNomePaciente.Name = "LblVerNomePaciente";
            this.LblVerNomePaciente.Size = new System.Drawing.Size(178, 24);
            this.LblVerNomePaciente.TabIndex = 0;
            this.LblVerNomePaciente.Text = "paciente";
            this.LblVerNomePaciente.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.LblVerNomePaciente.Visible = false;
            // 
            // LblVerNome
            // 
            this.LblVerNome.BackColor = System.Drawing.Color.Transparent;
            this.LblVerNome.Font = new System.Drawing.Font("Arial", 16.5F, System.Drawing.FontStyle.Bold);
            this.LblVerNome.Location = new System.Drawing.Point(24, 271);
            this.LblVerNome.Margin = new System.Windows.Forms.Padding(0);
            this.LblVerNome.Name = "LblVerNome";
            this.LblVerNome.Size = new System.Drawing.Size(85, 24);
            this.LblVerNome.TabIndex = 0;
            this.LblVerNome.Text = "Nome:";
            this.LblVerNome.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.LblVerNome.Visible = false;
            // 
            // PicBoxFotoPerfil
            // 
            this.PicBoxFotoPerfil.BackColor = System.Drawing.Color.Transparent;
            this.PicBoxFotoPerfil.Image = ((System.Drawing.Image)(resources.GetObject("PicBoxFotoPerfil.Image")));
            this.PicBoxFotoPerfil.Location = new System.Drawing.Point(61, 67);
            this.PicBoxFotoPerfil.Margin = new System.Windows.Forms.Padding(0);
            this.PicBoxFotoPerfil.Name = "PicBoxFotoPerfil";
            this.PicBoxFotoPerfil.Size = new System.Drawing.Size(180, 180);
            this.PicBoxFotoPerfil.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.PicBoxFotoPerfil.TabIndex = 2;
            this.PicBoxFotoPerfil.TabStop = false;
            this.PicBoxFotoPerfil.Visible = false;
            this.PicBoxFotoPerfil.Paint += new System.Windows.Forms.PaintEventHandler(this.PicBoxFotoPerfil_Paint);
            // 
            // PnlHistoricoMedico
            // 
            this.PnlHistoricoMedico.BackColor = System.Drawing.Color.Transparent;
            this.PnlHistoricoMedico.Controls.Add(this.PicBoxHistoricoMedico);
            this.PnlHistoricoMedico.Controls.Add(this.LblHistoricoMedico);
            this.PnlHistoricoMedico.Location = new System.Drawing.Point(196, 46);
            this.PnlHistoricoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.PnlHistoricoMedico.Name = "PnlHistoricoMedico";
            this.PnlHistoricoMedico.Size = new System.Drawing.Size(301, 411);
            this.PnlHistoricoMedico.TabIndex = 0;
            this.PnlHistoricoMedico.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlHistoricoMedico_Paint);
            // 
            // PicBoxHistoricoMedico
            // 
            this.PicBoxHistoricoMedico.BackColor = System.Drawing.Color.Transparent;
            this.PicBoxHistoricoMedico.Location = new System.Drawing.Point(0, 44);
            this.PicBoxHistoricoMedico.Margin = new System.Windows.Forms.Padding(0);
            this.PicBoxHistoricoMedico.Name = "PicBoxHistoricoMedico";
            this.PicBoxHistoricoMedico.Size = new System.Drawing.Size(301, 367);
            this.PicBoxHistoricoMedico.TabIndex = 1;
            this.PicBoxHistoricoMedico.TabStop = false;
            this.PicBoxHistoricoMedico.Visible = false;
            // 
            // LblHistoricoMedico
            // 
            this.LblHistoricoMedico.BackColor = System.Drawing.Color.Transparent;
            this.LblHistoricoMedico.Font = new System.Drawing.Font("Arial", 16.5F, System.Drawing.FontStyle.Bold);
            this.LblHistoricoMedico.Location = new System.Drawing.Point(3, 0);
            this.LblHistoricoMedico.Name = "LblHistoricoMedico";
            this.LblHistoricoMedico.Size = new System.Drawing.Size(297, 44);
            this.LblHistoricoMedico.TabIndex = 0;
            this.LblHistoricoMedico.Text = "Histórico Médico:";
            this.LblHistoricoMedico.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblHistoricoMedico.Paint += new System.Windows.Forms.PaintEventHandler(this.LblHistoricoMedico_Paint);
            // 
            // PnlVerPacientes
            // 
            this.PnlVerPacientes.AutoScroll = true;
            this.PnlVerPacientes.BackColor = System.Drawing.Color.Transparent;
            this.PnlVerPacientes.Location = new System.Drawing.Point(3, 46);
            this.PnlVerPacientes.Margin = new System.Windows.Forms.Padding(0);
            this.PnlVerPacientes.Name = "PnlVerPacientes";
            this.PnlVerPacientes.Size = new System.Drawing.Size(193, 408);
            this.PnlVerPacientes.TabIndex = 1;
            this.PnlVerPacientes.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlVerPacientes_Paint);
            // 
            // TelaFuncoesFuncHospital
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlFuncoes);
            this.MinimumSize = new System.Drawing.Size(900, 595);
            this.Name = "TelaFuncoesFuncHospital";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaFuncoesFuncHospital";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaFuncoesFuncHospital_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaFuncoesFuncHospital_FormClosed);
            this.Load += new System.EventHandler(this.TelaFuncoesFuncHospital_Load);
            this.PnlNavegacao.ResumeLayout(false);
            this.PnlFuncaoEmitirReceita.ResumeLayout(false);
            this.PnlTxtBoxSenha.ResumeLayout(false);
            this.PnlTxtBoxSenha.PerformLayout();
            this.PnlTxtBoxCPF.ResumeLayout(false);
            this.PnlTxtBoxCPF.PerformLayout();
            this.PnlTxtBoxMedicamento.ResumeLayout(false);
            this.PnlTxtBoxMedicamento.PerformLayout();
            this.PnlFuncoes.ResumeLayout(false);
            this.PnlFuncaoVerPacientes.ResumeLayout(false);
            this.PnlConteudoVer.ResumeLayout(false);
            this.PnlPesquisarCPF.ResumeLayout(false);
            this.PnlTxtBoxPesquisarCPF.ResumeLayout(false);
            this.PnlTxtBoxPesquisarCPF.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.PnlPerfilPaciente.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxFotoPerfil)).EndInit();
            this.PnlHistoricoMedico.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxHistoricoMedico)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlNavegacao;
        private System.Windows.Forms.Button BtnEmitirReceita;
        private System.Windows.Forms.Panel PnlFuncaoEmitirReceita;
        private System.Windows.Forms.Panel PnlTxtBoxDetalhes;
        private System.Windows.Forms.Label LblDataValidade;
        private System.Windows.Forms.Panel PnlTxtBoxSenha;
        private System.Windows.Forms.TextBox TxtSenha;
        private System.Windows.Forms.Label LblDetalhes;
        private System.Windows.Forms.Label LblSenha;
        private System.Windows.Forms.Panel PnlTxtBoxCPF;
        private System.Windows.Forms.TextBox TxtCPFPaciente;
        private System.Windows.Forms.Panel PnlTxtBoxMedicamento;
        private System.Windows.Forms.TextBox TxtMedicamento;
        private System.Windows.Forms.Label LblMedicamento;
        private System.Windows.Forms.Label LblCPFPaciente;
        private System.Windows.Forms.Button BtnEmitir;
        private System.Windows.Forms.Panel PnlFuncoes;
        private System.Windows.Forms.Button BtnVerPacientes;
        private System.Windows.Forms.Panel PnlFuncaoVerPacientes;
        private System.Windows.Forms.Panel PnlConteudoVer;
        private System.Windows.Forms.Panel PnlPesquisarCPF;
        private System.Windows.Forms.Panel PnlTxtBoxPesquisarCPF;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.TextBox TxtPesquisarCPF;
        private System.Windows.Forms.Panel PnlPerfilPaciente;
        private System.Windows.Forms.Label LblVerNomePaciente;
        private System.Windows.Forms.Label LblVerNome;
        private System.Windows.Forms.PictureBox PicBoxFotoPerfil;
        private System.Windows.Forms.Panel PnlHistoricoMedico;
        private System.Windows.Forms.PictureBox PicBoxHistoricoMedico;
        private System.Windows.Forms.Label LblHistoricoMedico;
        private System.Windows.Forms.Panel PnlVerPacientes;
        private System.Windows.Forms.DateTimePicker DataValidade;
        private System.Windows.Forms.Label LblLimiteBaixas;
        private System.Windows.Forms.ComboBox CmBoxLimitesBaixas;
        private System.Windows.Forms.Label LblVerCPFPaciente;
        private System.Windows.Forms.Label LblVerCPF;
    }
}
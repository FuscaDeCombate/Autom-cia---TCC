
namespace Automácia
{
    partial class TelaRecuperacaoDeSenha
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
            this.PnlRecSenha = new System.Windows.Forms.Panel();
            this.PnlTxtBoxSenha = new System.Windows.Forms.Panel();
            this.TxtNovaSenha = new System.Windows.Forms.TextBox();
            this.PnlTxtBoxCPF = new System.Windows.Forms.Panel();
            this.TxtCPF = new System.Windows.Forms.TextBox();
            this.LblNovaSenha = new System.Windows.Forms.Label();
            this.LblVoltar = new System.Windows.Forms.Label();
            this.LblCPF = new System.Windows.Forms.Label();
            this.BtnEnviarConfir = new System.Windows.Forms.Button();
            this.LblInforme = new System.Windows.Forms.Label();
            this.PnlRecSenha.SuspendLayout();
            this.PnlTxtBoxSenha.SuspendLayout();
            this.PnlTxtBoxCPF.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlRecSenha
            // 
            this.PnlRecSenha.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlRecSenha.BackColor = System.Drawing.Color.White;
            this.PnlRecSenha.Controls.Add(this.PnlTxtBoxSenha);
            this.PnlRecSenha.Controls.Add(this.PnlTxtBoxCPF);
            this.PnlRecSenha.Controls.Add(this.LblNovaSenha);
            this.PnlRecSenha.Controls.Add(this.LblVoltar);
            this.PnlRecSenha.Controls.Add(this.LblCPF);
            this.PnlRecSenha.Controls.Add(this.BtnEnviarConfir);
            this.PnlRecSenha.Controls.Add(this.LblInforme);
            this.PnlRecSenha.Location = new System.Drawing.Point(263, 38);
            this.PnlRecSenha.Name = "PnlRecSenha";
            this.PnlRecSenha.Size = new System.Drawing.Size(375, 525);
            this.PnlRecSenha.TabIndex = 16;
            // 
            // PnlTxtBoxSenha
            // 
            this.PnlTxtBoxSenha.Controls.Add(this.TxtNovaSenha);
            this.PnlTxtBoxSenha.Location = new System.Drawing.Point(40, 283);
            this.PnlTxtBoxSenha.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxSenha.Name = "PnlTxtBoxSenha";
            this.PnlTxtBoxSenha.Size = new System.Drawing.Size(294, 37);
            this.PnlTxtBoxSenha.TabIndex = 28;
            this.PnlTxtBoxSenha.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxNovaSenha_Paint);
            // 
            // TxtNovaSenha
            // 
            this.TxtNovaSenha.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtNovaSenha.Font = new System.Drawing.Font("Arial", 21.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtNovaSenha.Location = new System.Drawing.Point(1, 0);
            this.TxtNovaSenha.Margin = new System.Windows.Forms.Padding(0);
            this.TxtNovaSenha.MaxLength = 1000;
            this.TxtNovaSenha.Name = "TxtNovaSenha";
            this.TxtNovaSenha.Size = new System.Drawing.Size(292, 34);
            this.TxtNovaSenha.TabIndex = 16;
            // 
            // PnlTxtBoxCPF
            // 
            this.PnlTxtBoxCPF.Controls.Add(this.TxtCPF);
            this.PnlTxtBoxCPF.Location = new System.Drawing.Point(40, 184);
            this.PnlTxtBoxCPF.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxCPF.Name = "PnlTxtBoxCPF";
            this.PnlTxtBoxCPF.Size = new System.Drawing.Size(294, 37);
            this.PnlTxtBoxCPF.TabIndex = 27;
            this.PnlTxtBoxCPF.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxCPF_Paint);
            // 
            // TxtCPF
            // 
            this.TxtCPF.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtCPF.Font = new System.Drawing.Font("Arial", 21.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtCPF.Location = new System.Drawing.Point(1, 0);
            this.TxtCPF.Margin = new System.Windows.Forms.Padding(0);
            this.TxtCPF.MaxLength = 11;
            this.TxtCPF.Name = "TxtCPF";
            this.TxtCPF.Size = new System.Drawing.Size(292, 34);
            this.TxtCPF.TabIndex = 16;
            this.TxtCPF.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.TxtCPF_KeyPress);
            // 
            // LblNovaSenha
            // 
            this.LblNovaSenha.BackColor = System.Drawing.Color.Transparent;
            this.LblNovaSenha.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblNovaSenha.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblNovaSenha.Location = new System.Drawing.Point(35, 251);
            this.LblNovaSenha.Margin = new System.Windows.Forms.Padding(0);
            this.LblNovaSenha.Name = "LblNovaSenha";
            this.LblNovaSenha.Size = new System.Drawing.Size(304, 27);
            this.LblNovaSenha.TabIndex = 25;
            this.LblNovaSenha.Text = "Nova Senha";
            // 
            // LblVoltar
            // 
            this.LblVoltar.BackColor = System.Drawing.Color.Transparent;
            this.LblVoltar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblVoltar.Font = new System.Drawing.Font("Arial", 22F);
            this.LblVoltar.Location = new System.Drawing.Point(50, 433);
            this.LblVoltar.Margin = new System.Windows.Forms.Padding(0);
            this.LblVoltar.Name = "LblVoltar";
            this.LblVoltar.Size = new System.Drawing.Size(274, 73);
            this.LblVoltar.TabIndex = 24;
            this.LblVoltar.Text = "Voltar";
            this.LblVoltar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVoltar.Click += new System.EventHandler(this.LblVoltar_Click);
            // 
            // LblCPF
            // 
            this.LblCPF.BackColor = System.Drawing.Color.Transparent;
            this.LblCPF.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblCPF.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblCPF.Location = new System.Drawing.Point(35, 152);
            this.LblCPF.Margin = new System.Windows.Forms.Padding(0);
            this.LblCPF.Name = "LblCPF";
            this.LblCPF.Size = new System.Drawing.Size(304, 27);
            this.LblCPF.TabIndex = 23;
            this.LblCPF.Text = "CPF";
            // 
            // BtnEnviarConfir
            // 
            this.BtnEnviarConfir.BackColor = System.Drawing.Color.White;
            this.BtnEnviarConfir.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnEnviarConfir.FlatAppearance.BorderSize = 0;
            this.BtnEnviarConfir.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnEnviarConfir.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnEnviarConfir.Location = new System.Drawing.Point(50, 346);
            this.BtnEnviarConfir.Margin = new System.Windows.Forms.Padding(0);
            this.BtnEnviarConfir.Name = "BtnEnviarConfir";
            this.BtnEnviarConfir.Size = new System.Drawing.Size(274, 73);
            this.BtnEnviarConfir.TabIndex = 22;
            this.BtnEnviarConfir.Text = "Enviar confirmação pelo email";
            this.BtnEnviarConfir.UseVisualStyleBackColor = false;
            this.BtnEnviarConfir.Click += new System.EventHandler(this.BtnEnviarConfir_Click);
            this.BtnEnviarConfir.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnEnviarConfir_Paint);
            // 
            // LblInforme
            // 
            this.LblInforme.BackColor = System.Drawing.Color.Transparent;
            this.LblInforme.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblInforme.Font = new System.Drawing.Font("Arial", 28F, System.Drawing.FontStyle.Bold);
            this.LblInforme.Location = new System.Drawing.Point(15, 34);
            this.LblInforme.Margin = new System.Windows.Forms.Padding(0);
            this.LblInforme.Name = "LblInforme";
            this.LblInforme.Size = new System.Drawing.Size(345, 87);
            this.LblInforme.TabIndex = 12;
            this.LblInforme.Text = "Recuperação de senha";
            this.LblInforme.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaRecuperacaoDeSenha
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlRecSenha);
            this.MinimumSize = new System.Drawing.Size(900, 599);
            this.Name = "TelaRecuperacaoDeSenha";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaRecuperacaoDeSenha";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaRecuperacaoDeSenha_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaRecuperacaoDeSenha_FormClosed);
            this.Load += new System.EventHandler(this.TelaRecuperacaoDeSenha_Load);
            this.PnlRecSenha.ResumeLayout(false);
            this.PnlTxtBoxSenha.ResumeLayout(false);
            this.PnlTxtBoxSenha.PerformLayout();
            this.PnlTxtBoxCPF.ResumeLayout(false);
            this.PnlTxtBoxCPF.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlRecSenha;
        private System.Windows.Forms.Panel PnlTxtBoxSenha;
        private System.Windows.Forms.TextBox TxtNovaSenha;
        private System.Windows.Forms.Panel PnlTxtBoxCPF;
        private System.Windows.Forms.TextBox TxtCPF;
        private System.Windows.Forms.Label LblNovaSenha;
        private System.Windows.Forms.Label LblVoltar;
        private System.Windows.Forms.Label LblCPF;
        private System.Windows.Forms.Button BtnEnviarConfir;
        private System.Windows.Forms.Label LblInforme;
    }
}

namespace Automácia
{
    partial class TelaLoginFuncHospital
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
            this.PnlLogin = new System.Windows.Forms.Panel();
            this.PnlTxtBoxSenha = new System.Windows.Forms.Panel();
            this.TxtSenha = new System.Windows.Forms.TextBox();
            this.PnlTxtBoxCPF = new System.Windows.Forms.Panel();
            this.TxtCPF = new System.Windows.Forms.TextBox();
            this.LblEsqueceu = new System.Windows.Forms.Label();
            this.LblSenha = new System.Windows.Forms.Label();
            this.LblVoltar = new System.Windows.Forms.Label();
            this.LblCPF = new System.Windows.Forms.Label();
            this.BtnEntrar = new System.Windows.Forms.Button();
            this.LblInforme = new System.Windows.Forms.Label();
            this.PnlLogin.SuspendLayout();
            this.PnlTxtBoxSenha.SuspendLayout();
            this.PnlTxtBoxCPF.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlLogin
            // 
            this.PnlLogin.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlLogin.BackColor = System.Drawing.Color.White;
            this.PnlLogin.Controls.Add(this.PnlTxtBoxSenha);
            this.PnlLogin.Controls.Add(this.PnlTxtBoxCPF);
            this.PnlLogin.Controls.Add(this.LblEsqueceu);
            this.PnlLogin.Controls.Add(this.LblSenha);
            this.PnlLogin.Controls.Add(this.LblVoltar);
            this.PnlLogin.Controls.Add(this.LblCPF);
            this.PnlLogin.Controls.Add(this.BtnEntrar);
            this.PnlLogin.Controls.Add(this.LblInforme);
            this.PnlLogin.Location = new System.Drawing.Point(263, 38);
            this.PnlLogin.Name = "PnlLogin";
            this.PnlLogin.Size = new System.Drawing.Size(375, 525);
            this.PnlLogin.TabIndex = 14;
            // 
            // PnlTxtBoxSenha
            // 
            this.PnlTxtBoxSenha.Controls.Add(this.TxtSenha);
            this.PnlTxtBoxSenha.Location = new System.Drawing.Point(40, 255);
            this.PnlTxtBoxSenha.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxSenha.Name = "PnlTxtBoxSenha";
            this.PnlTxtBoxSenha.Size = new System.Drawing.Size(294, 37);
            this.PnlTxtBoxSenha.TabIndex = 28;
            this.PnlTxtBoxSenha.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxSenha_Paint);
            // 
            // TxtSenha
            // 
            this.TxtSenha.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtSenha.Font = new System.Drawing.Font("Arial", 21.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtSenha.Location = new System.Drawing.Point(1, 0);
            this.TxtSenha.Margin = new System.Windows.Forms.Padding(0);
            this.TxtSenha.MaxLength = 1000;
            this.TxtSenha.Name = "TxtSenha";
            this.TxtSenha.Size = new System.Drawing.Size(292, 34);
            this.TxtSenha.TabIndex = 16;
            // 
            // PnlTxtBoxCPF
            // 
            this.PnlTxtBoxCPF.Controls.Add(this.TxtCPF);
            this.PnlTxtBoxCPF.Location = new System.Drawing.Point(40, 156);
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
            // LblEsqueceu
            // 
            this.LblEsqueceu.BackColor = System.Drawing.Color.Transparent;
            this.LblEsqueceu.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblEsqueceu.Font = new System.Drawing.Font("Arial", 13F);
            this.LblEsqueceu.ForeColor = System.Drawing.Color.Gray;
            this.LblEsqueceu.Location = new System.Drawing.Point(41, 302);
            this.LblEsqueceu.Margin = new System.Windows.Forms.Padding(0);
            this.LblEsqueceu.Name = "LblEsqueceu";
            this.LblEsqueceu.Size = new System.Drawing.Size(293, 27);
            this.LblEsqueceu.TabIndex = 26;
            this.LblEsqueceu.Text = "Esqueceu a senha?";
            this.LblEsqueceu.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblEsqueceu.Click += new System.EventHandler(this.LblEsqueceu_Click);
            // 
            // LblSenha
            // 
            this.LblSenha.BackColor = System.Drawing.Color.Transparent;
            this.LblSenha.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblSenha.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblSenha.Location = new System.Drawing.Point(35, 223);
            this.LblSenha.Margin = new System.Windows.Forms.Padding(0);
            this.LblSenha.Name = "LblSenha";
            this.LblSenha.Size = new System.Drawing.Size(304, 27);
            this.LblSenha.TabIndex = 25;
            this.LblSenha.Text = "Senha";
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
            this.LblCPF.Location = new System.Drawing.Point(35, 124);
            this.LblCPF.Margin = new System.Windows.Forms.Padding(0);
            this.LblCPF.Name = "LblCPF";
            this.LblCPF.Size = new System.Drawing.Size(304, 27);
            this.LblCPF.TabIndex = 23;
            this.LblCPF.Text = "CPF";
            // 
            // BtnEntrar
            // 
            this.BtnEntrar.BackColor = System.Drawing.Color.White;
            this.BtnEntrar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnEntrar.FlatAppearance.BorderSize = 0;
            this.BtnEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnEntrar.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnEntrar.Location = new System.Drawing.Point(50, 346);
            this.BtnEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnEntrar.Name = "BtnEntrar";
            this.BtnEntrar.Size = new System.Drawing.Size(274, 73);
            this.BtnEntrar.TabIndex = 22;
            this.BtnEntrar.Text = "Entrar";
            this.BtnEntrar.UseVisualStyleBackColor = false;
            this.BtnEntrar.Click += new System.EventHandler(this.BtnEntrar_Click);
            this.BtnEntrar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnEntrar_Paint);
            // 
            // LblInforme
            // 
            this.LblInforme.BackColor = System.Drawing.Color.Transparent;
            this.LblInforme.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblInforme.Font = new System.Drawing.Font("Arial", 32.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblInforme.Location = new System.Drawing.Point(75, 37);
            this.LblInforme.Margin = new System.Windows.Forms.Padding(0);
            this.LblInforme.Name = "LblInforme";
            this.LblInforme.Size = new System.Drawing.Size(225, 57);
            this.LblInforme.TabIndex = 12;
            this.LblInforme.Text = "Informe";
            this.LblInforme.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaLoginFuncHospital
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlLogin);
            this.MinimumSize = new System.Drawing.Size(900, 599);
            this.Name = "TelaLoginFuncHospital";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaLoginFuncHospital";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaLoginFuncHospital_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaLoginFuncHospital_FormClosed);
            this.Load += new System.EventHandler(this.TelaLoginFuncHospital_Load);
            this.PnlLogin.ResumeLayout(false);
            this.PnlTxtBoxSenha.ResumeLayout(false);
            this.PnlTxtBoxSenha.PerformLayout();
            this.PnlTxtBoxCPF.ResumeLayout(false);
            this.PnlTxtBoxCPF.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlLogin;
        private System.Windows.Forms.Label LblInforme;
        private System.Windows.Forms.Panel PnlTxtBoxSenha;
        private System.Windows.Forms.TextBox TxtSenha;
        private System.Windows.Forms.Panel PnlTxtBoxCPF;
        private System.Windows.Forms.TextBox TxtCPF;
        private System.Windows.Forms.Label LblEsqueceu;
        private System.Windows.Forms.Label LblSenha;
        private System.Windows.Forms.Label LblVoltar;
        private System.Windows.Forms.Label LblCPF;
        private System.Windows.Forms.Button BtnEntrar;
    }
}
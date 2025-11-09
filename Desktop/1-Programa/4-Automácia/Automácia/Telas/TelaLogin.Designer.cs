
namespace Automácia
{
    partial class TelaLogin
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
            this.PnlTxtBoxID = new System.Windows.Forms.Panel();
            this.TxtID = new System.Windows.Forms.TextBox();
            this.LblSenha = new System.Windows.Forms.Label();
            this.LblID = new System.Windows.Forms.Label();
            this.BtnEntrar = new System.Windows.Forms.Button();
            this.LblInforme = new System.Windows.Forms.Label();
            this.PnlLogin.SuspendLayout();
            this.PnlTxtBoxSenha.SuspendLayout();
            this.PnlTxtBoxID.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlLogin
            // 
            this.PnlLogin.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlLogin.BackColor = System.Drawing.Color.White;
            this.PnlLogin.Controls.Add(this.PnlTxtBoxSenha);
            this.PnlLogin.Controls.Add(this.PnlTxtBoxID);
            this.PnlLogin.Controls.Add(this.LblSenha);
            this.PnlLogin.Controls.Add(this.LblID);
            this.PnlLogin.Controls.Add(this.BtnEntrar);
            this.PnlLogin.Controls.Add(this.LblInforme);
            this.PnlLogin.Location = new System.Drawing.Point(351, 47);
            this.PnlLogin.Margin = new System.Windows.Forms.Padding(4);
            this.PnlLogin.Name = "PnlLogin";
            this.PnlLogin.Size = new System.Drawing.Size(500, 646);
            this.PnlLogin.TabIndex = 0;
            // 
            // PnlTxtBoxSenha
            // 
            this.PnlTxtBoxSenha.Controls.Add(this.TxtSenha);
            this.PnlTxtBoxSenha.Location = new System.Drawing.Point(53, 377);
            this.PnlTxtBoxSenha.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxSenha.Name = "PnlTxtBoxSenha";
            this.PnlTxtBoxSenha.Size = new System.Drawing.Size(392, 46);
            this.PnlTxtBoxSenha.TabIndex = 2;
            this.PnlTxtBoxSenha.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxSenha_Paint);
            // 
            // TxtSenha
            // 
            this.TxtSenha.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtSenha.Font = new System.Drawing.Font("Arial", 21.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtSenha.Location = new System.Drawing.Point(1, 0);
            this.TxtSenha.Margin = new System.Windows.Forms.Padding(0);
            this.TxtSenha.MaxLength = 256;
            this.TxtSenha.Name = "TxtSenha";
            this.TxtSenha.Size = new System.Drawing.Size(389, 42);
            this.TxtSenha.TabIndex = 0;
            this.TxtSenha.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            // 
            // PnlTxtBoxID
            // 
            this.PnlTxtBoxID.Controls.Add(this.TxtID);
            this.PnlTxtBoxID.Location = new System.Drawing.Point(53, 222);
            this.PnlTxtBoxID.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxID.Name = "PnlTxtBoxID";
            this.PnlTxtBoxID.Size = new System.Drawing.Size(392, 46);
            this.PnlTxtBoxID.TabIndex = 1;
            this.PnlTxtBoxID.Paint += new System.Windows.Forms.PaintEventHandler(this.PnlTxtBoxCPF_Paint);
            // 
            // TxtID
            // 
            this.TxtID.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtID.Font = new System.Drawing.Font("Arial", 21.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtID.Location = new System.Drawing.Point(1, 0);
            this.TxtID.Margin = new System.Windows.Forms.Padding(0);
            this.TxtID.MaxLength = 15;
            this.TxtID.Name = "TxtID";
            this.TxtID.Size = new System.Drawing.Size(389, 42);
            this.TxtID.TabIndex = 0;
            this.TxtID.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            this.TxtID.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.TxtCPF_KeyPress);
            // 
            // LblSenha
            // 
            this.LblSenha.BackColor = System.Drawing.Color.Transparent;
            this.LblSenha.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblSenha.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblSenha.Location = new System.Drawing.Point(47, 338);
            this.LblSenha.Margin = new System.Windows.Forms.Padding(0);
            this.LblSenha.Name = "LblSenha";
            this.LblSenha.Size = new System.Drawing.Size(405, 33);
            this.LblSenha.TabIndex = 0;
            this.LblSenha.Text = "Senha";
            // 
            // LblID
            // 
            this.LblID.BackColor = System.Drawing.Color.Transparent;
            this.LblID.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblID.Font = new System.Drawing.Font("Arial Narrow", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblID.Location = new System.Drawing.Point(47, 181);
            this.LblID.Margin = new System.Windows.Forms.Padding(0);
            this.LblID.Name = "LblID";
            this.LblID.Size = new System.Drawing.Size(405, 33);
            this.LblID.TabIndex = 0;
            this.LblID.Text = "ID";
            // 
            // BtnEntrar
            // 
            this.BtnEntrar.BackColor = System.Drawing.Color.White;
            this.BtnEntrar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.BtnEntrar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnEntrar.FlatAppearance.BorderSize = 0;
            this.BtnEntrar.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(230)))), ((int)(((byte)(230)))));
            this.BtnEntrar.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(205)))), ((int)(((byte)(205)))), ((int)(((byte)(205)))));
            this.BtnEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnEntrar.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnEntrar.Location = new System.Drawing.Point(67, 505);
            this.BtnEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnEntrar.Name = "BtnEntrar";
            this.BtnEntrar.Size = new System.Drawing.Size(365, 90);
            this.BtnEntrar.TabIndex = 3;
            this.BtnEntrar.Text = "Entrar";
            this.BtnEntrar.UseVisualStyleBackColor = false;
            this.BtnEntrar.Click += new System.EventHandler(this.BtnEntrar_Click);
            this.BtnEntrar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnEntrar_Paint);
            this.BtnEntrar.KeyDown += new System.Windows.Forms.KeyEventHandler(this.RedirecionarProximo_KeyDown);
            // 
            // LblInforme
            // 
            this.LblInforme.BackColor = System.Drawing.Color.Transparent;
            this.LblInforme.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblInforme.Font = new System.Drawing.Font("Arial", 32.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblInforme.Location = new System.Drawing.Point(100, 49);
            this.LblInforme.Margin = new System.Windows.Forms.Padding(0);
            this.LblInforme.Name = "LblInforme";
            this.LblInforme.Size = new System.Drawing.Size(300, 70);
            this.LblInforme.TabIndex = 0;
            this.LblInforme.Text = "Informe";
            this.LblInforme.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaLogin
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(1200, 738);
            this.Controls.Add(this.PnlLogin);
            this.Margin = new System.Windows.Forms.Padding(4);
            this.MinimumSize = new System.Drawing.Size(1194, 726);
            this.Name = "TelaLogin";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Login - Automácia";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaLoginFuncHospital_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaLoginFuncHospital_FormClosed);
            this.Load += new System.EventHandler(this.TelaLoginFuncHospital_Load);
            this.PnlLogin.ResumeLayout(false);
            this.PnlTxtBoxSenha.ResumeLayout(false);
            this.PnlTxtBoxSenha.PerformLayout();
            this.PnlTxtBoxID.ResumeLayout(false);
            this.PnlTxtBoxID.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlLogin;
        private System.Windows.Forms.Label LblInforme;
        private System.Windows.Forms.Panel PnlTxtBoxSenha;
        private System.Windows.Forms.TextBox TxtSenha;
        private System.Windows.Forms.Panel PnlTxtBoxID;
        private System.Windows.Forms.TextBox TxtID;
        private System.Windows.Forms.Label LblSenha;
        private System.Windows.Forms.Label LblID;
        private System.Windows.Forms.Button BtnEntrar;
    }
}
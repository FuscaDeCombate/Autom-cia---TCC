namespace Automácia
{
    partial class TelaEntrarHospital
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TelaEntrarHospital));
            this.PnlEntrar = new System.Windows.Forms.Panel();
            this.LblVoltar = new System.Windows.Forms.Label();
            this.LblMembroHospital = new System.Windows.Forms.Label();
            this.BtnAdministrador = new System.Windows.Forms.Button();
            this.BtnFuncionario = new System.Windows.Forms.Button();
            this.PicBoxLogo = new System.Windows.Forms.PictureBox();
            this.LblEntrar = new System.Windows.Forms.Label();
            this.PnlEntrar.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).BeginInit();
            this.SuspendLayout();
            // 
            // PnlEntrar
            // 
            this.PnlEntrar.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlEntrar.BackColor = System.Drawing.Color.White;
            this.PnlEntrar.Controls.Add(this.LblVoltar);
            this.PnlEntrar.Controls.Add(this.LblMembroHospital);
            this.PnlEntrar.Controls.Add(this.BtnAdministrador);
            this.PnlEntrar.Controls.Add(this.BtnFuncionario);
            this.PnlEntrar.Controls.Add(this.PicBoxLogo);
            this.PnlEntrar.Controls.Add(this.LblEntrar);
            this.PnlEntrar.Location = new System.Drawing.Point(263, 38);
            this.PnlEntrar.Name = "PnlEntrar";
            this.PnlEntrar.Size = new System.Drawing.Size(375, 525);
            this.PnlEntrar.TabIndex = 2;
            // 
            // LblVoltar
            // 
            this.LblVoltar.BackColor = System.Drawing.Color.Transparent;
            this.LblVoltar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblVoltar.Font = new System.Drawing.Font("Arial", 22F);
            this.LblVoltar.Location = new System.Drawing.Point(50, 434);
            this.LblVoltar.Margin = new System.Windows.Forms.Padding(0);
            this.LblVoltar.Name = "LblVoltar";
            this.LblVoltar.Size = new System.Drawing.Size(274, 73);
            this.LblVoltar.TabIndex = 13;
            this.LblVoltar.Text = "Voltar";
            this.LblVoltar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVoltar.Click += new System.EventHandler(this.LblVoltar_Click);
            // 
            // LblMembroHospital
            // 
            this.LblMembroHospital.BackColor = System.Drawing.Color.Transparent;
            this.LblMembroHospital.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblMembroHospital.Font = new System.Drawing.Font("Arial Narrow", 21.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMembroHospital.Location = new System.Drawing.Point(47, 179);
            this.LblMembroHospital.Margin = new System.Windows.Forms.Padding(0);
            this.LblMembroHospital.Name = "LblMembroHospital";
            this.LblMembroHospital.Size = new System.Drawing.Size(280, 70);
            this.LblMembroHospital.TabIndex = 12;
            this.LblMembroHospital.Text = "Como membro do Hospital";
            this.LblMembroHospital.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // BtnAdministrador
            // 
            this.BtnAdministrador.BackColor = System.Drawing.Color.White;
            this.BtnAdministrador.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnAdministrador.FlatAppearance.BorderSize = 0;
            this.BtnAdministrador.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnAdministrador.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnAdministrador.Location = new System.Drawing.Point(50, 353);
            this.BtnAdministrador.Margin = new System.Windows.Forms.Padding(0);
            this.BtnAdministrador.Name = "BtnAdministrador";
            this.BtnAdministrador.Size = new System.Drawing.Size(274, 73);
            this.BtnAdministrador.TabIndex = 11;
            this.BtnAdministrador.Text = "Administrador";
            this.BtnAdministrador.UseVisualStyleBackColor = false;
            this.BtnAdministrador.Click += new System.EventHandler(this.BtnAdministrador_Click);
            this.BtnAdministrador.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnAdministrador_Paint);
            // 
            // BtnFuncionario
            // 
            this.BtnFuncionario.FlatAppearance.BorderSize = 0;
            this.BtnFuncionario.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnFuncionario.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnFuncionario.Location = new System.Drawing.Point(50, 263);
            this.BtnFuncionario.Margin = new System.Windows.Forms.Padding(0);
            this.BtnFuncionario.Name = "BtnFuncionario";
            this.BtnFuncionario.Size = new System.Drawing.Size(274, 73);
            this.BtnFuncionario.TabIndex = 10;
            this.BtnFuncionario.Text = "Funcionário";
            this.BtnFuncionario.UseVisualStyleBackColor = true;
            this.BtnFuncionario.Click += new System.EventHandler(this.BtnFuncionario_Click);
            this.BtnFuncionario.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnFuncionario_Paint);
            // 
            // PicBoxLogo
            // 
            this.PicBoxLogo.BackColor = System.Drawing.Color.Transparent;
            this.PicBoxLogo.ErrorImage = null;
            this.PicBoxLogo.Image = ((System.Drawing.Image)(resources.GetObject("PicBoxLogo.Image")));
            this.PicBoxLogo.InitialImage = ((System.Drawing.Image)(resources.GetObject("PicBoxLogo.InitialImage")));
            this.PicBoxLogo.Location = new System.Drawing.Point(142, 17);
            this.PicBoxLogo.Margin = new System.Windows.Forms.Padding(0);
            this.PicBoxLogo.Name = "PicBoxLogo";
            this.PicBoxLogo.Size = new System.Drawing.Size(90, 90);
            this.PicBoxLogo.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.PicBoxLogo.TabIndex = 9;
            this.PicBoxLogo.TabStop = false;
            this.PicBoxLogo.Paint += new System.Windows.Forms.PaintEventHandler(this.PicBoxLogo_Paint);
            // 
            // LblEntrar
            // 
            this.LblEntrar.BackColor = System.Drawing.Color.Transparent;
            this.LblEntrar.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblEntrar.Font = new System.Drawing.Font("Arial", 32.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblEntrar.Location = new System.Drawing.Point(75, 115);
            this.LblEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.LblEntrar.Name = "LblEntrar";
            this.LblEntrar.Size = new System.Drawing.Size(225, 57);
            this.LblEntrar.TabIndex = 8;
            this.LblEntrar.Text = "Entrar";
            this.LblEntrar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaEntrarHospital
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlEntrar);
            this.MinimumSize = new System.Drawing.Size(900, 600);
            this.Name = "TelaEntrarHospital";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaEntrarHospital";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaEntrarHospital_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaEntrarHospital_FormClosed);
            this.Load += new System.EventHandler(this.TelaEntrarHospital_Load);
            this.PnlEntrar.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Panel PnlEntrar;
        private System.Windows.Forms.Label LblVoltar;
        private System.Windows.Forms.Label LblMembroHospital;
        private System.Windows.Forms.Button BtnAdministrador;
        private System.Windows.Forms.Button BtnFuncionario;
        private System.Windows.Forms.PictureBox PicBoxLogo;
        private System.Windows.Forms.Label LblEntrar;
    }
}
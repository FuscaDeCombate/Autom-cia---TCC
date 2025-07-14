namespace Automácia
{
    partial class TelaEntrarFarmacia
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TelaEntrarFarmacia));
            this.PnlEntrar = new System.Windows.Forms.Panel();
            this.LblVoltar = new System.Windows.Forms.Label();
            this.LblMembroFarmacia = new System.Windows.Forms.Label();
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
            this.PnlEntrar.Controls.Add(this.LblMembroFarmacia);
            this.PnlEntrar.Controls.Add(this.BtnAdministrador);
            this.PnlEntrar.Controls.Add(this.BtnFuncionario);
            this.PnlEntrar.Controls.Add(this.PicBoxLogo);
            this.PnlEntrar.Controls.Add(this.LblEntrar);
            this.PnlEntrar.Location = new System.Drawing.Point(263, 38);
            this.PnlEntrar.Name = "PnlEntrar";
            this.PnlEntrar.Size = new System.Drawing.Size(375, 525);
            this.PnlEntrar.TabIndex = 3;
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
            this.LblVoltar.TabIndex = 9;
            this.LblVoltar.Text = "Voltar";
            this.LblVoltar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVoltar.Click += new System.EventHandler(this.LblVoltar_Click);
            // 
            // LblMembroFarmacia
            // 
            this.LblMembroFarmacia.BackColor = System.Drawing.Color.Transparent;
            this.LblMembroFarmacia.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblMembroFarmacia.Font = new System.Drawing.Font("Arial Narrow", 21.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMembroFarmacia.Location = new System.Drawing.Point(52, 179);
            this.LblMembroFarmacia.Margin = new System.Windows.Forms.Padding(0);
            this.LblMembroFarmacia.Name = "LblMembroFarmacia";
            this.LblMembroFarmacia.Size = new System.Drawing.Size(270, 70);
            this.LblMembroFarmacia.TabIndex = 10;
            this.LblMembroFarmacia.Text = "Como membro da Farmácia";
            this.LblMembroFarmacia.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // BtnAdministrador
            // 
            this.BtnAdministrador.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnAdministrador.FlatAppearance.BorderSize = 0;
            this.BtnAdministrador.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnAdministrador.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnAdministrador.Location = new System.Drawing.Point(50, 353);
            this.BtnAdministrador.Margin = new System.Windows.Forms.Padding(0);
            this.BtnAdministrador.Name = "BtnAdministrador";
            this.BtnAdministrador.Size = new System.Drawing.Size(274, 73);
            this.BtnAdministrador.TabIndex = 8;
            this.BtnAdministrador.Text = "Administrador";
            this.BtnAdministrador.UseVisualStyleBackColor = true;
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
            this.BtnFuncionario.TabIndex = 6;
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
            this.PicBoxLogo.TabIndex = 7;
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
            this.LblEntrar.TabIndex = 5;
            this.LblEntrar.Text = "Entrar";
            this.LblEntrar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaEntrarFarmacia
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlEntrar);
            this.MinimumSize = new System.Drawing.Size(900, 600);
            this.Name = "TelaEntrarFarmacia";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaEntrarFarmacia";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaEntrarFarmacia_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaEntrarFarmacia_FormClosed);
            this.Load += new System.EventHandler(this.TelaEntrarFarmacia_Load);
            this.PnlEntrar.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlEntrar;
        private System.Windows.Forms.Label LblVoltar;
        private System.Windows.Forms.Label LblMembroFarmacia;
        private System.Windows.Forms.Button BtnAdministrador;
        private System.Windows.Forms.Button BtnFuncionario;
        private System.Windows.Forms.PictureBox PicBoxLogo;
        private System.Windows.Forms.Label LblEntrar;
    }
}
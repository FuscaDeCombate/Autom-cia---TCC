namespace Automácia
{
    partial class TelaInicio
    {
        /// <summary>
        /// Variável de designer necessária.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpar os recursos que estão sendo usados.
        /// </summary>
        /// <param name="disposing">true se for necessário descartar os recursos gerenciados; caso contrário, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código gerado pelo Windows Form Designer

        /// <summary>
        /// Método necessário para suporte ao Designer - não modifique 
        /// o conteúdo deste método com o editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TelaInicio));
            this.PnlEntrar = new System.Windows.Forms.Panel();
            this.BtnFarmaciaEntrar = new System.Windows.Forms.Button();
            this.BtnHospitalEntrar = new System.Windows.Forms.Button();
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
            this.PnlEntrar.Controls.Add(this.BtnFarmaciaEntrar);
            this.PnlEntrar.Controls.Add(this.BtnHospitalEntrar);
            this.PnlEntrar.Controls.Add(this.PicBoxLogo);
            this.PnlEntrar.Controls.Add(this.LblEntrar);
            this.PnlEntrar.Location = new System.Drawing.Point(263, 38);
            this.PnlEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.PnlEntrar.Name = "PnlEntrar";
            this.PnlEntrar.Size = new System.Drawing.Size(375, 525);
            this.PnlEntrar.TabIndex = 1;
            // 
            // BtnFarmaciaEntrar
            // 
            this.BtnFarmaciaEntrar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnFarmaciaEntrar.FlatAppearance.BorderSize = 0;
            this.BtnFarmaciaEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnFarmaciaEntrar.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnFarmaciaEntrar.Location = new System.Drawing.Point(50, 379);
            this.BtnFarmaciaEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnFarmaciaEntrar.Name = "BtnFarmaciaEntrar";
            this.BtnFarmaciaEntrar.Size = new System.Drawing.Size(274, 73);
            this.BtnFarmaciaEntrar.TabIndex = 6;
            this.BtnFarmaciaEntrar.Text = "Farmácia";
            this.BtnFarmaciaEntrar.UseVisualStyleBackColor = true;
            this.BtnFarmaciaEntrar.Click += new System.EventHandler(this.BtnFarmaciaEntrar_Click);
            this.BtnFarmaciaEntrar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnFarmaciaEntrar_Paint);
            // 
            // BtnHospitalEntrar
            // 
            this.BtnHospitalEntrar.FlatAppearance.BorderSize = 0;
            this.BtnHospitalEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnHospitalEntrar.Font = new System.Drawing.Font("Arial", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.BtnHospitalEntrar.Location = new System.Drawing.Point(50, 255);
            this.BtnHospitalEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnHospitalEntrar.Name = "BtnHospitalEntrar";
            this.BtnHospitalEntrar.Size = new System.Drawing.Size(274, 73);
            this.BtnHospitalEntrar.TabIndex = 4;
            this.BtnHospitalEntrar.Text = "Hospital";
            this.BtnHospitalEntrar.UseVisualStyleBackColor = true;
            this.BtnHospitalEntrar.Click += new System.EventHandler(this.BtnHospitalEntrar_Click);
            this.BtnHospitalEntrar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnHospitalEntrar_Paint);
            // 
            // PicBoxLogo
            // 
            this.PicBoxLogo.BackColor = System.Drawing.Color.Transparent;
            this.PicBoxLogo.ErrorImage = null;
            this.PicBoxLogo.Image = ((System.Drawing.Image)(resources.GetObject("PicBoxLogo.Image")));
            this.PicBoxLogo.InitialImage = null;
            this.PicBoxLogo.Location = new System.Drawing.Point(142, 33);
            this.PicBoxLogo.Margin = new System.Windows.Forms.Padding(0);
            this.PicBoxLogo.Name = "PicBoxLogo";
            this.PicBoxLogo.Size = new System.Drawing.Size(90, 90);
            this.PicBoxLogo.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.PicBoxLogo.TabIndex = 5;
            this.PicBoxLogo.TabStop = false;
            this.PicBoxLogo.Paint += new System.Windows.Forms.PaintEventHandler(this.PicBoxLogo_Paint);
            // 
            // LblEntrar
            // 
            this.LblEntrar.BackColor = System.Drawing.Color.Transparent;
            this.LblEntrar.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblEntrar.Font = new System.Drawing.Font("Arial", 32.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblEntrar.Location = new System.Drawing.Point(75, 144);
            this.LblEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.LblEntrar.Name = "LblEntrar";
            this.LblEntrar.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.LblEntrar.Size = new System.Drawing.Size(225, 57);
            this.LblEntrar.TabIndex = 3;
            this.LblEntrar.Text = "Entrar";
            this.LblEntrar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaInicio
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlEntrar);
            this.ForeColor = System.Drawing.SystemColors.ControlText;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MinimumSize = new System.Drawing.Size(900, 599);
            this.Name = "TelaInicio";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Tela Início";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaInicio_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaInicio_FormClosed);
            this.Load += new System.EventHandler(this.TelaInicio_Load);
            this.PnlEntrar.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlEntrar;
        private System.Windows.Forms.Button BtnFarmaciaEntrar;
        private System.Windows.Forms.Button BtnHospitalEntrar;
        private System.Windows.Forms.PictureBox PicBoxLogo;
        private System.Windows.Forms.Label LblEntrar;
    }
}


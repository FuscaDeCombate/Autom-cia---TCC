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
            this.GroupEntrar = new System.Windows.Forms.GroupBox();
            this.BtnFarmaciaEntrar = new System.Windows.Forms.Button();
            this.BtnHospitalEntrar = new System.Windows.Forms.Button();
            this.PicBoxLogo = new System.Windows.Forms.PictureBox();
            this.LblEntrar = new System.Windows.Forms.Label();
            this.GroupEntrar.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).BeginInit();
            this.SuspendLayout();
            // 
            // GroupEntrar
            // 
            this.GroupEntrar.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.GroupEntrar.BackColor = System.Drawing.Color.White;
            this.GroupEntrar.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.GroupEntrar.Controls.Add(this.BtnFarmaciaEntrar);
            this.GroupEntrar.Controls.Add(this.BtnHospitalEntrar);
            this.GroupEntrar.Controls.Add(this.PicBoxLogo);
            this.GroupEntrar.Controls.Add(this.LblEntrar);
            this.GroupEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.GroupEntrar.ForeColor = System.Drawing.SystemColors.ControlText;
            this.GroupEntrar.Location = new System.Drawing.Point(263, 38);
            this.GroupEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.GroupEntrar.Name = "GroupEntrar";
            this.GroupEntrar.Padding = new System.Windows.Forms.Padding(0);
            this.GroupEntrar.Size = new System.Drawing.Size(375, 525);
            this.GroupEntrar.TabIndex = 0;
            this.GroupEntrar.TabStop = false;
            // 
            // BtnFarmaciaEntrar
            // 
            this.BtnFarmaciaEntrar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnFarmaciaEntrar.FlatAppearance.BorderSize = 0;
            this.BtnFarmaciaEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnFarmaciaEntrar.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnFarmaciaEntrar.Location = new System.Drawing.Point(50, 381);
            this.BtnFarmaciaEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnFarmaciaEntrar.Name = "BtnFarmaciaEntrar";
            this.BtnFarmaciaEntrar.Size = new System.Drawing.Size(274, 73);
            this.BtnFarmaciaEntrar.TabIndex = 3;
            this.BtnFarmaciaEntrar.Text = "Farmácia";
            this.BtnFarmaciaEntrar.UseVisualStyleBackColor = true;
            this.BtnFarmaciaEntrar.Click += new System.EventHandler(this.BtnFarmaciaEntrar_Click);
            this.BtnFarmaciaEntrar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnFarmaciaEntrar_Paint);
            // 
            // BtnHospitalEntrar
            // 
            this.BtnHospitalEntrar.FlatAppearance.BorderSize = 0;
            this.BtnHospitalEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnHospitalEntrar.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnHospitalEntrar.Location = new System.Drawing.Point(50, 256);
            this.BtnHospitalEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnHospitalEntrar.Name = "BtnHospitalEntrar";
            this.BtnHospitalEntrar.Size = new System.Drawing.Size(274, 73);
            this.BtnHospitalEntrar.TabIndex = 2;
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
            this.PicBoxLogo.InitialImage = ((System.Drawing.Image)(resources.GetObject("PicBoxLogo.InitialImage")));
            this.PicBoxLogo.Location = new System.Drawing.Point(140, 32);
            this.PicBoxLogo.Margin = new System.Windows.Forms.Padding(0);
            this.PicBoxLogo.Name = "PicBoxLogo";
            this.PicBoxLogo.Size = new System.Drawing.Size(94, 94);
            this.PicBoxLogo.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.PicBoxLogo.TabIndex = 1;
            this.PicBoxLogo.TabStop = false;
            this.PicBoxLogo.Paint += new System.Windows.Forms.PaintEventHandler(this.PicBoxLogo_Paint);
            // 
            // LblEntrar
            // 
            this.LblEntrar.BackColor = System.Drawing.Color.Transparent;
            this.LblEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblEntrar.Font = new System.Drawing.Font("Arial", 32.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblEntrar.Location = new System.Drawing.Point(75, 145);
            this.LblEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.LblEntrar.Name = "LblEntrar";
            this.LblEntrar.Size = new System.Drawing.Size(225, 57);
            this.LblEntrar.TabIndex = 0;
            this.LblEntrar.Text = "Entrar";
            this.LblEntrar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TelaInicio
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.GroupEntrar);
            this.ForeColor = System.Drawing.SystemColors.ControlText;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MinimumSize = new System.Drawing.Size(900, 600);
            this.Name = "TelaInicio";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Tela Início";
            this.Load += new System.EventHandler(this.TelaInicio_Load);
            this.GroupEntrar.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox GroupEntrar;
        private System.Windows.Forms.PictureBox PicBoxLogo;
        private System.Windows.Forms.Label LblEntrar;
        private System.Windows.Forms.Button BtnFarmaciaEntrar;
        private System.Windows.Forms.Button BtnHospitalEntrar;
    }
}


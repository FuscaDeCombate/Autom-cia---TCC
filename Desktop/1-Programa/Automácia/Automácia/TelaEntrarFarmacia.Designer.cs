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
            this.GroupEntrar = new System.Windows.Forms.GroupBox();
            this.LblMembroFarmacia = new System.Windows.Forms.Label();
            this.BtnAdministrador = new System.Windows.Forms.Button();
            this.BtnFuncionario = new System.Windows.Forms.Button();
            this.PicBoxLogo = new System.Windows.Forms.PictureBox();
            this.LblEntrar = new System.Windows.Forms.Label();
            this.LblVoltar = new System.Windows.Forms.Label();
            this.GroupEntrar.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).BeginInit();
            this.SuspendLayout();
            // 
            // GroupEntrar
            // 
            this.GroupEntrar.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.GroupEntrar.BackColor = System.Drawing.Color.White;
            this.GroupEntrar.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.GroupEntrar.Controls.Add(this.LblVoltar);
            this.GroupEntrar.Controls.Add(this.LblMembroFarmacia);
            this.GroupEntrar.Controls.Add(this.BtnAdministrador);
            this.GroupEntrar.Controls.Add(this.BtnFuncionario);
            this.GroupEntrar.Controls.Add(this.PicBoxLogo);
            this.GroupEntrar.Controls.Add(this.LblEntrar);
            this.GroupEntrar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.GroupEntrar.ForeColor = System.Drawing.SystemColors.ControlText;
            this.GroupEntrar.Location = new System.Drawing.Point(263, 38);
            this.GroupEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.GroupEntrar.Name = "GroupEntrar";
            this.GroupEntrar.Padding = new System.Windows.Forms.Padding(0);
            this.GroupEntrar.Size = new System.Drawing.Size(375, 525);
            this.GroupEntrar.TabIndex = 2;
            this.GroupEntrar.TabStop = false;
            // 
            // LblMembroFarmacia
            // 
            this.LblMembroFarmacia.BackColor = System.Drawing.Color.Transparent;
            this.LblMembroFarmacia.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblMembroFarmacia.Font = new System.Drawing.Font("Arial Narrow", 21.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblMembroFarmacia.Location = new System.Drawing.Point(52, 178);
            this.LblMembroFarmacia.Margin = new System.Windows.Forms.Padding(0);
            this.LblMembroFarmacia.Name = "LblMembroFarmacia";
            this.LblMembroFarmacia.Size = new System.Drawing.Size(270, 70);
            this.LblMembroFarmacia.TabIndex = 4;
            this.LblMembroFarmacia.Text = "Como membro do Farmácia";
            this.LblMembroFarmacia.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // BtnAdministrador
            // 
            this.BtnAdministrador.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnAdministrador.FlatAppearance.BorderSize = 0;
            this.BtnAdministrador.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnAdministrador.Font = new System.Drawing.Font("Arial", 20F);
            this.BtnAdministrador.Location = new System.Drawing.Point(50, 350);
            this.BtnAdministrador.Margin = new System.Windows.Forms.Padding(0);
            this.BtnAdministrador.Name = "BtnAdministrador";
            this.BtnAdministrador.Size = new System.Drawing.Size(274, 73);
            this.BtnAdministrador.TabIndex = 3;
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
            this.BtnFuncionario.Location = new System.Drawing.Point(50, 262);
            this.BtnFuncionario.Margin = new System.Windows.Forms.Padding(0);
            this.BtnFuncionario.Name = "BtnFuncionario";
            this.BtnFuncionario.Size = new System.Drawing.Size(274, 73);
            this.BtnFuncionario.TabIndex = 2;
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
            this.PicBoxLogo.Location = new System.Drawing.Point(140, 18);
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
            this.LblEntrar.Location = new System.Drawing.Point(75, 121);
            this.LblEntrar.Margin = new System.Windows.Forms.Padding(0);
            this.LblEntrar.Name = "LblEntrar";
            this.LblEntrar.Size = new System.Drawing.Size(225, 57);
            this.LblEntrar.TabIndex = 0;
            this.LblEntrar.Text = "Entrar";
            this.LblEntrar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // LblVoltar
            // 
            this.LblVoltar.BackColor = System.Drawing.Color.Transparent;
            this.LblVoltar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblVoltar.Font = new System.Drawing.Font("Arial", 22F);
            this.LblVoltar.Location = new System.Drawing.Point(50, 432);
            this.LblVoltar.Margin = new System.Windows.Forms.Padding(0);
            this.LblVoltar.Name = "LblVoltar";
            this.LblVoltar.Size = new System.Drawing.Size(274, 73);
            this.LblVoltar.TabIndex = 6;
            this.LblVoltar.Text = "Voltar";
            this.LblVoltar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVoltar.Click += new System.EventHandler(this.LblSair_Click);
            // 
            // TelaEntrarFarmacia
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.GroupEntrar);
            this.MinimumSize = new System.Drawing.Size(900, 600);
            this.Name = "TelaEntrarFarmacia";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaEntrarFarmacia";
            this.Load += new System.EventHandler(this.TelaEntrarFarmacia_Load);
            this.GroupEntrar.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxLogo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox GroupEntrar;
        private System.Windows.Forms.Label LblMembroFarmacia;
        private System.Windows.Forms.Button BtnAdministrador;
        private System.Windows.Forms.Button BtnFuncionario;
        private System.Windows.Forms.PictureBox PicBoxLogo;
        private System.Windows.Forms.Label LblEntrar;
        private System.Windows.Forms.Label LblVoltar;
    }
}
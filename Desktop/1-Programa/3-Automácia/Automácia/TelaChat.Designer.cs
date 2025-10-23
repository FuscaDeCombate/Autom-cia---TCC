namespace Automácia
{
    partial class TelaChat
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TelaChat));
            this.PnlChat = new System.Windows.Forms.Panel();
            this.LstBoxMensagens = new System.Windows.Forms.ListBox();
            this.panel2 = new System.Windows.Forms.Panel();
            this.LblNomePaciente = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.PnlTxtBoxMensagem = new System.Windows.Forms.Panel();
            this.PicBoxEnviar = new System.Windows.Forms.PictureBox();
            this.TxtMensagem = new System.Windows.Forms.TextBox();
            this.tmChat = new System.Windows.Forms.Timer(this.components);
            this.PnlChat.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel1.SuspendLayout();
            this.PnlTxtBoxMensagem.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxEnviar)).BeginInit();
            this.SuspendLayout();
            // 
            // PnlChat
            // 
            this.PnlChat.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlChat.BackColor = System.Drawing.Color.White;
            this.PnlChat.Controls.Add(this.LstBoxMensagens);
            this.PnlChat.Controls.Add(this.panel2);
            this.PnlChat.Controls.Add(this.panel1);
            this.PnlChat.Location = new System.Drawing.Point(12, 9);
            this.PnlChat.Margin = new System.Windows.Forms.Padding(0);
            this.PnlChat.Name = "PnlChat";
            this.PnlChat.Size = new System.Drawing.Size(310, 582);
            this.PnlChat.TabIndex = 0;
            // 
            // LstBoxMensagens
            // 
            this.LstBoxMensagens.FormattingEnabled = true;
            this.LstBoxMensagens.Items.AddRange(new object[] {
            "  "});
            this.LstBoxMensagens.Location = new System.Drawing.Point(0, 47);
            this.LstBoxMensagens.Margin = new System.Windows.Forms.Padding(0);
            this.LstBoxMensagens.Name = "LstBoxMensagens";
            this.LstBoxMensagens.Size = new System.Drawing.Size(310, 485);
            this.LstBoxMensagens.TabIndex = 0;
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.LblNomePaciente);
            this.panel2.Location = new System.Drawing.Point(0, 0);
            this.panel2.Margin = new System.Windows.Forms.Padding(0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(310, 45);
            this.panel2.TabIndex = 0;
            // 
            // LblNomePaciente
            // 
            this.LblNomePaciente.BackColor = System.Drawing.Color.Transparent;
            this.LblNomePaciente.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblNomePaciente.Font = new System.Drawing.Font("Arial", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblNomePaciente.Location = new System.Drawing.Point(43, 5);
            this.LblNomePaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblNomePaciente.Name = "LblNomePaciente";
            this.LblNomePaciente.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.LblNomePaciente.Size = new System.Drawing.Size(225, 35);
            this.LblNomePaciente.TabIndex = 0;
            this.LblNomePaciente.Text = "Paciente";
            this.LblNomePaciente.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.PnlTxtBoxMensagem);
            this.panel1.Location = new System.Drawing.Point(0, 527);
            this.panel1.Margin = new System.Windows.Forms.Padding(0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(310, 55);
            this.panel1.TabIndex = 1;
            // 
            // PnlTxtBoxMensagem
            // 
            this.PnlTxtBoxMensagem.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.PnlTxtBoxMensagem.Controls.Add(this.PicBoxEnviar);
            this.PnlTxtBoxMensagem.Controls.Add(this.TxtMensagem);
            this.PnlTxtBoxMensagem.Location = new System.Drawing.Point(12, 10);
            this.PnlTxtBoxMensagem.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxMensagem.Name = "PnlTxtBoxMensagem";
            this.PnlTxtBoxMensagem.Size = new System.Drawing.Size(287, 35);
            this.PnlTxtBoxMensagem.TabIndex = 0;
            // 
            // PicBoxEnviar
            // 
            this.PicBoxEnviar.BackColor = System.Drawing.Color.White;
            this.PicBoxEnviar.ErrorImage = null;
            this.PicBoxEnviar.Image = ((System.Drawing.Image)(resources.GetObject("PicBoxEnviar.Image")));
            this.PicBoxEnviar.InitialImage = null;
            this.PicBoxEnviar.Location = new System.Drawing.Point(255, 3);
            this.PicBoxEnviar.Margin = new System.Windows.Forms.Padding(0);
            this.PicBoxEnviar.Name = "PicBoxEnviar";
            this.PicBoxEnviar.Size = new System.Drawing.Size(28, 28);
            this.PicBoxEnviar.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.PicBoxEnviar.TabIndex = 36;
            this.PicBoxEnviar.TabStop = false;
            this.PicBoxEnviar.Click += new System.EventHandler(this.PicBoxEnviar_Click);
            this.PicBoxEnviar.Paint += new System.Windows.Forms.PaintEventHandler(this.PicBoxEnviar_Paint);
            this.PicBoxEnviar.MouseEnter += new System.EventHandler(this.PicBoxEnviar_MouseEnter);
            this.PicBoxEnviar.MouseLeave += new System.EventHandler(this.PicBoxEnviar_MouseLeave);
            // 
            // TxtMensagem
            // 
            this.TxtMensagem.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.TxtMensagem.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtMensagem.Font = new System.Drawing.Font("Arial", 15.5F);
            this.TxtMensagem.Location = new System.Drawing.Point(8, 5);
            this.TxtMensagem.Margin = new System.Windows.Forms.Padding(0);
            this.TxtMensagem.MaxLength = 500;
            this.TxtMensagem.Name = "TxtMensagem";
            this.TxtMensagem.Size = new System.Drawing.Size(240, 24);
            this.TxtMensagem.TabIndex = 0;
            this.TxtMensagem.KeyDown += new System.Windows.Forms.KeyEventHandler(this.TxtMensagem_KeyDown);
            // 
            // tmChat
            // 
            this.tmChat.Enabled = true;
            this.tmChat.Interval = 1000;
            this.tmChat.Tick += new System.EventHandler(this.tmChat_Tick);
            // 
            // TelaChat
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(334, 600);
            this.Controls.Add(this.PnlChat);
            this.MinimumSize = new System.Drawing.Size(300, 599);
            this.Name = "TelaChat";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaChat";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaChat_FormClosing);
            this.Load += new System.EventHandler(this.TelaChat_Load);
            this.PnlChat.ResumeLayout(false);
            this.panel2.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.PnlTxtBoxMensagem.ResumeLayout(false);
            this.PnlTxtBoxMensagem.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PicBoxEnviar)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlChat;
        private System.Windows.Forms.Label LblNomePaciente;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel PnlTxtBoxMensagem;
        private System.Windows.Forms.PictureBox PicBoxEnviar;
        private System.Windows.Forms.TextBox TxtMensagem;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.ListBox LstBoxMensagens;
        private System.Windows.Forms.Timer tmChat;
    }
}
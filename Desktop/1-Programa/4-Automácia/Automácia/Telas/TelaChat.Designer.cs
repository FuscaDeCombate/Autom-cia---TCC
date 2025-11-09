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
            this.PnlMensagens = new System.Windows.Forms.Panel();
            this.FlowPnlMensagens = new System.Windows.Forms.FlowLayoutPanel();
            this.PnlNome = new System.Windows.Forms.Panel();
            this.LblNomePaciente = new System.Windows.Forms.Label();
            this.PnlTextBoxMensagens = new System.Windows.Forms.Panel();
            this.PnlTxtBoxMensagem = new System.Windows.Forms.Panel();
            this.BtnEnviar = new System.Windows.Forms.Button();
            this.TxtMensagem = new System.Windows.Forms.TextBox();
            this.tmChat = new System.Windows.Forms.Timer(this.components);
            this.PnlChat.SuspendLayout();
            this.PnlMensagens.SuspendLayout();
            this.PnlNome.SuspendLayout();
            this.PnlTextBoxMensagens.SuspendLayout();
            this.PnlTxtBoxMensagem.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlChat
            // 
            this.PnlChat.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlChat.BackColor = System.Drawing.Color.WhiteSmoke;
            this.PnlChat.Controls.Add(this.PnlMensagens);
            this.PnlChat.Controls.Add(this.PnlNome);
            this.PnlChat.Controls.Add(this.PnlTextBoxMensagens);
            this.PnlChat.Location = new System.Drawing.Point(12, 9);
            this.PnlChat.Margin = new System.Windows.Forms.Padding(0);
            this.PnlChat.Name = "PnlChat";
            this.PnlChat.Size = new System.Drawing.Size(360, 582);
            this.PnlChat.TabIndex = 0;
            // 
            // PnlMensagens
            // 
            this.PnlMensagens.BackColor = System.Drawing.Color.WhiteSmoke;
            this.PnlMensagens.Controls.Add(this.FlowPnlMensagens);
            this.PnlMensagens.Location = new System.Drawing.Point(0, 51);
            this.PnlMensagens.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.PnlMensagens.Name = "PnlMensagens";
            this.PnlMensagens.Size = new System.Drawing.Size(365, 474);
            this.PnlMensagens.TabIndex = 2;
            // 
            // FlowPnlMensagens
            // 
            this.FlowPnlMensagens.AutoScroll = true;
            this.FlowPnlMensagens.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(235)))), ((int)(((byte)(235)))), ((int)(((byte)(235)))));
            this.FlowPnlMensagens.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            this.FlowPnlMensagens.Location = new System.Drawing.Point(0, 0);
            this.FlowPnlMensagens.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.FlowPnlMensagens.Name = "FlowPnlMensagens";
            this.FlowPnlMensagens.Size = new System.Drawing.Size(360, 474);
            this.FlowPnlMensagens.TabIndex = 0;
            this.FlowPnlMensagens.WrapContents = false;
            // 
            // PnlNome
            // 
            this.PnlNome.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(26)))), ((int)(((byte)(110)))));
            this.PnlNome.Controls.Add(this.LblNomePaciente);
            this.PnlNome.Location = new System.Drawing.Point(0, 0);
            this.PnlNome.Margin = new System.Windows.Forms.Padding(0);
            this.PnlNome.Name = "PnlNome";
            this.PnlNome.Size = new System.Drawing.Size(360, 49);
            this.PnlNome.TabIndex = 0;
            // 
            // LblNomePaciente
            // 
            this.LblNomePaciente.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(26)))), ((int)(((byte)(110)))));
            this.LblNomePaciente.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblNomePaciente.Font = new System.Drawing.Font("Arial", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LblNomePaciente.ForeColor = System.Drawing.Color.White;
            this.LblNomePaciente.Location = new System.Drawing.Point(68, 6);
            this.LblNomePaciente.Margin = new System.Windows.Forms.Padding(0);
            this.LblNomePaciente.Name = "LblNomePaciente";
            this.LblNomePaciente.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.LblNomePaciente.Size = new System.Drawing.Size(225, 31);
            this.LblNomePaciente.TabIndex = 0;
            this.LblNomePaciente.Text = "Paciente";
            this.LblNomePaciente.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // PnlTextBoxMensagens
            // 
            this.PnlTextBoxMensagens.BackColor = System.Drawing.Color.White;
            this.PnlTextBoxMensagens.Controls.Add(this.PnlTxtBoxMensagem);
            this.PnlTextBoxMensagens.Location = new System.Drawing.Point(0, 527);
            this.PnlTextBoxMensagens.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTextBoxMensagens.Name = "PnlTextBoxMensagens";
            this.PnlTextBoxMensagens.Size = new System.Drawing.Size(360, 55);
            this.PnlTextBoxMensagens.TabIndex = 1;
            // 
            // PnlTxtBoxMensagem
            // 
            this.PnlTxtBoxMensagem.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.PnlTxtBoxMensagem.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.PnlTxtBoxMensagem.Controls.Add(this.BtnEnviar);
            this.PnlTxtBoxMensagem.Controls.Add(this.TxtMensagem);
            this.PnlTxtBoxMensagem.Location = new System.Drawing.Point(10, 7);
            this.PnlTxtBoxMensagem.Margin = new System.Windows.Forms.Padding(0);
            this.PnlTxtBoxMensagem.Name = "PnlTxtBoxMensagem";
            this.PnlTxtBoxMensagem.Size = new System.Drawing.Size(340, 40);
            this.PnlTxtBoxMensagem.TabIndex = 0;
            // 
            // BtnEnviar
            // 
            this.BtnEnviar.BackColor = System.Drawing.Color.White;
            this.BtnEnviar.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("BtnEnviar.BackgroundImage")));
            this.BtnEnviar.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.BtnEnviar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.BtnEnviar.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.BtnEnviar.FlatAppearance.BorderSize = 0;
            this.BtnEnviar.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(255)))), ((int)(((byte)(50)))));
            this.BtnEnviar.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Lime;
            this.BtnEnviar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnEnviar.Location = new System.Drawing.Point(305, 3);
            this.BtnEnviar.Margin = new System.Windows.Forms.Padding(0);
            this.BtnEnviar.Name = "BtnEnviar";
            this.BtnEnviar.Size = new System.Drawing.Size(30, 32);
            this.BtnEnviar.TabIndex = 0;
            this.BtnEnviar.UseVisualStyleBackColor = false;
            this.BtnEnviar.Click += new System.EventHandler(this.BtnEnviar_Click);
            this.BtnEnviar.Paint += new System.Windows.Forms.PaintEventHandler(this.BtnEnviar_Paint);
            // 
            // TxtMensagem
            // 
            this.TxtMensagem.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.TxtMensagem.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.TxtMensagem.Font = new System.Drawing.Font("Arial", 15F);
            this.TxtMensagem.Location = new System.Drawing.Point(8, 8);
            this.TxtMensagem.Margin = new System.Windows.Forms.Padding(0);
            this.TxtMensagem.MaxLength = 500;
            this.TxtMensagem.Name = "TxtMensagem";
            this.TxtMensagem.Size = new System.Drawing.Size(290, 23);
            this.TxtMensagem.TabIndex = 0;
            this.TxtMensagem.Text = "  ";
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
            this.ClientSize = new System.Drawing.Size(384, 600);
            this.Controls.Add(this.PnlChat);
            this.MinimumSize = new System.Drawing.Size(300, 596);
            this.Name = "TelaChat";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Chat - Automácia";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaChat_FormClosing);
            this.Load += new System.EventHandler(this.TelaChat_Load);
            this.PnlChat.ResumeLayout(false);
            this.PnlMensagens.ResumeLayout(false);
            this.PnlNome.ResumeLayout(false);
            this.PnlTextBoxMensagens.ResumeLayout(false);
            this.PnlTxtBoxMensagem.ResumeLayout(false);
            this.PnlTxtBoxMensagem.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlChat;
        private System.Windows.Forms.Label LblNomePaciente;
        private System.Windows.Forms.Panel PnlTextBoxMensagens;
        private System.Windows.Forms.Panel PnlTxtBoxMensagem;
        private System.Windows.Forms.TextBox TxtMensagem;
        private System.Windows.Forms.Panel PnlNome;
        private System.Windows.Forms.Timer tmChat;
        private System.Windows.Forms.Panel PnlMensagens;
        private System.Windows.Forms.FlowLayoutPanel FlowPnlMensagens;
        private System.Windows.Forms.Button BtnEnviar;
    }
}
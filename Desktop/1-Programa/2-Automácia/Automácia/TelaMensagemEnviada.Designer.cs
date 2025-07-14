
namespace Automácia
{
    partial class TelaMensagemEnviada
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
            this.PnlMensagemEnviada = new System.Windows.Forms.Panel();
            this.LblConfirmar = new System.Windows.Forms.Label();
            this.LblEmail = new System.Windows.Forms.Label();
            this.LblMensagem = new System.Windows.Forms.Label();
            this.LblVoltar = new System.Windows.Forms.Label();
            this.PnlMensagemEnviada.SuspendLayout();
            this.SuspendLayout();
            // 
            // PnlMensagemEnviada
            // 
            this.PnlMensagemEnviada.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.PnlMensagemEnviada.BackColor = System.Drawing.Color.White;
            this.PnlMensagemEnviada.Controls.Add(this.LblConfirmar);
            this.PnlMensagemEnviada.Controls.Add(this.LblEmail);
            this.PnlMensagemEnviada.Controls.Add(this.LblMensagem);
            this.PnlMensagemEnviada.Controls.Add(this.LblVoltar);
            this.PnlMensagemEnviada.Location = new System.Drawing.Point(263, 90);
            this.PnlMensagemEnviada.Name = "PnlMensagemEnviada";
            this.PnlMensagemEnviada.Size = new System.Drawing.Size(375, 420);
            this.PnlMensagemEnviada.TabIndex = 17;
            // 
            // LblConfirmar
            // 
            this.LblConfirmar.BackColor = System.Drawing.Color.Transparent;
            this.LblConfirmar.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblConfirmar.Font = new System.Drawing.Font("Arial", 18F);
            this.LblConfirmar.Location = new System.Drawing.Point(56, 230);
            this.LblConfirmar.Margin = new System.Windows.Forms.Padding(0);
            this.LblConfirmar.Name = "LblConfirmar";
            this.LblConfirmar.Size = new System.Drawing.Size(262, 85);
            this.LblConfirmar.TabIndex = 28;
            this.LblConfirmar.Text = "Depois de confirmar volte e tente entrar novamente";
            this.LblConfirmar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // LblEmail
            // 
            this.LblEmail.BackColor = System.Drawing.Color.Transparent;
            this.LblEmail.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblEmail.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Bold);
            this.LblEmail.Location = new System.Drawing.Point(37, 166);
            this.LblEmail.Margin = new System.Windows.Forms.Padding(0);
            this.LblEmail.Name = "LblEmail";
            this.LblEmail.Size = new System.Drawing.Size(300, 28);
            this.LblEmail.TabIndex = 27;
            this.LblEmail.Text = "a********n@email.com";
            this.LblEmail.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // LblMensagem
            // 
            this.LblMensagem.BackColor = System.Drawing.Color.Transparent;
            this.LblMensagem.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.LblMensagem.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Bold);
            this.LblMensagem.Location = new System.Drawing.Point(56, 46);
            this.LblMensagem.Margin = new System.Windows.Forms.Padding(0);
            this.LblMensagem.Name = "LblMensagem";
            this.LblMensagem.Size = new System.Drawing.Size(262, 85);
            this.LblMensagem.TabIndex = 26;
            this.LblMensagem.Text = "Mensagem de confirmação enviada para o email:\r\n\r\n";
            this.LblMensagem.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // LblVoltar
            // 
            this.LblVoltar.BackColor = System.Drawing.Color.Transparent;
            this.LblVoltar.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblVoltar.Font = new System.Drawing.Font("Arial", 22F);
            this.LblVoltar.Location = new System.Drawing.Point(50, 330);
            this.LblVoltar.Margin = new System.Windows.Forms.Padding(0);
            this.LblVoltar.Name = "LblVoltar";
            this.LblVoltar.Size = new System.Drawing.Size(274, 73);
            this.LblVoltar.TabIndex = 25;
            this.LblVoltar.Text = "Voltar";
            this.LblVoltar.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.LblVoltar.Click += new System.EventHandler(this.LblVoltar_Click);
            // 
            // TelaMensagemEnviada
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(53)))), ((int)(((byte)(110)))));
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.PnlMensagemEnviada);
            this.MinimumSize = new System.Drawing.Size(900, 599);
            this.Name = "TelaMensagemEnviada";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TelaMensagemEnviada";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TelaMensagemEnviada_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.TelaMensagemEnviada_FormClosed);
            this.Load += new System.EventHandler(this.TelaMensagemEnviada_Load);
            this.PnlMensagemEnviada.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PnlMensagemEnviada;
        private System.Windows.Forms.Label LblVoltar;
        private System.Windows.Forms.Label LblConfirmar;
        private System.Windows.Forms.Label LblEmail;
        private System.Windows.Forms.Label LblMensagem;
    }
}
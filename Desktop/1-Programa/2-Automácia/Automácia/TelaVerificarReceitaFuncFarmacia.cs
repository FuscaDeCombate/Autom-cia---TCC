using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    public partial class TelaVerificarReceitaFuncFarmacia : Form
    {
        [DllImport("Gdi32.dll", EntryPoint = "CreateRoundRectRgn")]
        private static extern IntPtr CreateRoundRectRgn
        (
            int nLeftRect,
            int nTopRect,
            int nRightRect,
            int nBottomRect,
            int nWidthEllipse,
            int nHeightEllipse
        );
        static Random rd = new Random();

        public TelaVerificarReceitaFuncFarmacia()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }

        private void TelaVerificarReceitaFuncFarmacia_Load(object sender, EventArgs e)
        {
            EstiloUtils.ArredondarTudo(PnlVerificarReceita, 15);
            EstiloUtils.ArredondarTudo(BtnPesquisar, 30);

            FonteUtils.AplicarFonte(TxtIDReceita, "Inter-Regular", 16.5f, FontStyle.Regular);

            FonteUtils.AplicarFonte(LblVerificarReceita, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblIDReceita, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNomeCompletoDoPaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblUso, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblInfoMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDataDeValidade, "Inter-Bold", 16.5f, FontStyle.Bold);

            FonteUtils.AplicarFonte(LblExibirNomeCompletoDoPaciente, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblMedicamentos, "Inter-Regular", 13f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirNomeCompletoMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirCRMMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirDataValidade, "Inter-Regular", 16.5f, FontStyle.Regular);

            FonteUtils.AplicarFonte(LblReceitaInvalida, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblMotivoReceitaInvalida, "Inter-Regular", 16.5f, FontStyle.Regular);

            FonteUtils.AplicarFonte(BtnPesquisar, "Inter-Medium", 16.5f, FontStyle.Regular);
        }


        private void PnlPrescricao_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

            using (Pen dashedPen = new Pen(Color.Black, 1))
            {
                int radius = 1;
                dashedPen.DashStyle = System.Drawing.Drawing2D.DashStyle.Dash;

                Rectangle rect = new Rectangle(0, 0, PnlPrescricao.Width - 1, PnlPrescricao.Height - 1);

                GraphicsPath path = new GraphicsPath();

                path.AddArc(rect.X, rect.Y, radius, radius, 180, 90); // canto superior esquerdo
                path.AddArc(rect.Right - radius, rect.Y, radius, radius, 270, 90); // superior direito
                path.AddArc(rect.Right - radius, rect.Bottom - radius, radius, radius, 0, 90); // inferior direito
                path.AddArc(rect.X, rect.Bottom - radius, radius, radius, 90, 90); // inferior esquerdo
                path.CloseFigure();

                e.Graphics.DrawPath(dashedPen, path);
            }
        }

        private void PnlVerificarReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 5, 12, Color.Black);
        }

        private void LblVerificarReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 5, false, true, false, false, Color.Black);
        }

        private void PnlTxtBoxIDReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        private void BtnPesquisar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }

        private void BtnPesquisar_Click(object sender, EventArgs e)
        {
            if (BtnPesquisar.Text == "Registrar Uso")
            {
                TxtIDReceita.Text = "";
                PnlInformacoes.Visible = false;
                PnlResultadoVerificacao.Visible = false;
                BtnPesquisar.Text = "Pesquisar";
                MessageBox.Show("Uso Registrado!");
                return;
            }

            if (TxtIDReceita.Text != "" && TxtIDReceita.Text.Length == 12)
            {
                string data = "";
                int dia = rd.Next(1, 30);
                int mes = rd.Next(1, 12);
                if (mes == 2)
                {
                    dia = rd.Next(1, 27);
                }
                int ano = rd.Next(1950, 2025);

                if (dia < 10)
                {
                    data += "0";
                }
                data += dia + "/";

                if (mes < 10)
                {
                    data += "0";
                }
                data += mes + "/";

                data += ano;

                PnlInformacoes.Visible = true;
                PnlResultadoVerificacao.Visible = false;
                //LblExibirNomeCompletoDoPaciente.Text = "";
                //LblMedicamentos.Text = "";
                //LblExibirNomeCompletoMedico.Text = "";
                LblExibirDataValidade.Text = data;
                BtnPesquisar.Text = "Registrar Uso";
            }
            else
            {
                PnlInformacoes.Visible = false;
                PnlResultadoVerificacao.Visible = true;
                LblMotivoReceitaInvalida.Text = "Receita não Encontrada";
            }
        }

        private void TelaVerificarReceitaFuncFarmacia_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!Sessao.saindo)
            {
                var confirmar = MessageBox.Show("Deseja realmente sair?", "Sair", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (confirmar == DialogResult.Yes)
                {
                    Sessao.saindo = true; // marca como já confirmado
                    Application.Exit();   // fecha tudo
                }
                else
                {
                    e.Cancel = true; // cancela o fechamento
                }
            }
        }

        private void TelaVerificarReceitaFuncFarmacia_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}

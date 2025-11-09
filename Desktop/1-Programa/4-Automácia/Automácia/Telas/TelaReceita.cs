using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    public partial class TelaReceita : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Parte do Chat---------
        // Variável sobre as Coordenadas do Forms
        Valores valores = new Valores();

        Receita receita = null;

        public TelaReceita(Receita receita_)
        {
            InitializeComponent();

            receita = receita_;

            this.Text = $"Receita {receita.Id} - Automácia";
        }

        private void TelaReceita_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Parte da Receita--------------------------------------------
            //----------Arredondar o Painel Principal----------
            EstiloUtils.ArredondarTudo(PnlReceita, 12);


            //----------Aplicar a fonte personalizada nos controles----------
            // Labels 1 - Títulos
            FonteUtils.AplicarFonte(LblReceita, "Inter-Bold", 17f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPFPaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNomeCompletoDoMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblUso, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblIDMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblLimiteBaixas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblBaixas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDataDeValidade, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDataDeCriacao, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblHorarioDeCriacao, "Inter-Bold", 16.5f, FontStyle.Bold);

            // Labels 2 - Valores
            FonteUtils.AplicarFonte(LblExibirCPFPaciente, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirNomeCompletoDoMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblMedicamentos, "Inter-Regular", 13f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirIDMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirLimiteBaixas, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirBaixas, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirDataValidade, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirDataCriacao, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirHorarioCriacao, "Inter-Regular", 16.5f, FontStyle.Regular);


            //----------Insere os Dados da Receita----------
            LblReceita.Text = "Receita " + receita.Id.ToString();
            LblExibirCPFPaciente.Text = receita.IdPaciente;
            LblExibirNomeCompletoDoMedico.Text = receita.NomeFuncionario;
            LblUso.Text = receita.Medicamento;
            LblMedicamentos.Text = receita.Detalhes;
            LblExibirIDMedico.Text = receita.IdFuncionario;
            LblExibirLimiteBaixas.Text = receita.LimitesBaixas.ToString();
            LblExibirBaixas.Text = receita.Baixas.ToString();
            LblExibirDataValidade.Text = receita.DataValidade.ToString("dd/MM/yyyy");
            LblExibirDataCriacao.Text = receita.DataReceita.ToString("dd/MM/yyyy");
            LblExibirHorarioCriacao.Text = receita.DataReceita.ToString("HH:mm:ss");
        }



        //---------------------------------------------Parte de Verificar Receita--------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo Personalizado do Panel da Prescrição
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

        // Fundo do Label da Receita
        private void LblReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 5, false, true, false, false, Color.Black);
        }



        //---------------------------------------------Parte de fechar o programa---------------------------------------------
        //----------Evento ativado quando o formulário estiver sendo fechado----------
        private void TelaReceita_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Para cancelar o fechamento
            e.Cancel = true;

            // Para pegar as variáveis das Coordenadas do Chat
            int X = this.Location.X;
            int Y = this.Location.Y;

            // Para pegar o valor Anterior das Coordenadas do Chat
            Point ponto = valores.CoordenadaReceita;

            // Para verificar se o Chat está perto de onde foi gerado
            if ((ponto.X - 8 < X && X < ponto.X + 8) && (ponto.Y - 8 < Y && Y < ponto.Y + 8))
            {
                // Se sim, reseta o valor Anterior das Coordenadas do Chat
                valores.CoordenadaReceita = new Point();
            }
            else
            {
                // Se não, guarda o valor Anterior das Coordenadas do Chat
                valores.CoordenadaReceita = new Point(X, Y);
            }

            // Para fechar
            e.Cancel = false;
        }
    }
}

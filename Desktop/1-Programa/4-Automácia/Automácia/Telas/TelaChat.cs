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
    public partial class TelaChat : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Parte do Chat---------
        // Variável sobre as Coordenadas do Forms
        Valores valores = new Valores();

        // Variáveis sobre o Paciente
        String nomePaciente = "";
        String cpfPaciente = "";

        // Variável sobre a Data Anterior das Mensagens
        DateTime dataAntiga = new DateTime();

        // Lista dos Ids das Mensagens
        List<int> idMensagens = new List<int>();



        public TelaChat(String nome_Paciente, String cpf_Paciente)
        {
            InitializeComponent();

            // Atribuindo o valor das variávies sobre o Paciente
            nomePaciente = nome_Paciente;
            cpfPaciente = cpf_Paciente;

            this.Text = $"{nomePaciente} - Chat - Automácia";
        }



        private void TelaChat_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Parte do Chat--------------------------------------------
            //----------Arredondar o Painel Principal----------
            EstiloUtils.ArredondarTudo(PnlChat, 12);


            //----------Arredondar controles----------
            // PictureBoxs
            EstiloUtils.ArredondarTudo(BtnEnviar, 35);

            // Panels
            EstiloUtils.ArredondarTudo(PnlTxtBoxMensagem, 35);


            //----------Aplicar a fonte personalizada nos controles----------
            // Textboxs
            FonteUtils.AplicarFonte(TxtMensagem, "Inter-Regular", 15f, FontStyle.Regular);

            // FlowLayoutPanels
            FonteUtils.AplicarFonte(FlowPnlMensagens, "Inter-Regular", 10f, FontStyle.Regular);


            //----------Atribuir Valores Iniciais----------
            // Nome
            LblNomePaciente.Text = nomePaciente;

            // FlowLayoutPanel das Mensagens
            FlowPnlMensagens.AutoScroll = true;
            FlowPnlMensagens.WrapContents = false;
            FlowPnlMensagens.FlowDirection = FlowDirection.TopDown;


            //----------Iniciar Chat----------
            // Para resetar o TxtMensagem
            TxtMensagem.BackColor = Color.FromArgb(224, 224, 224);
            TxtMensagem.Refresh();
            TxtMensagem.Focus();

            MostrarChat();
        }



        //---------------------------------------------Parte do Chat--------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo do Button de Enviar
        private void BtnEnviar_Paint(object sender, PaintEventArgs e)
        {
            // Para verificar se tem texto ou não para mudar a cor
            if (string.IsNullOrWhiteSpace(TxtMensagem.Text))
            {
                BtnEnviar.BackColor = Color.White;
            }
            else
            {
                BtnEnviar.BackColor = Color.FromArgb(0, 255, 0);
            }
        }


        //----------Evento KeyDown dos Elementos----------
        // TexBox da Mensagem
        private void TxtMensagem_KeyDown(object sender, KeyEventArgs e)
        {
            // Verificar se a tecla apertada foi Enter
            if (e.KeyCode == Keys.Enter)
            {
                EnviarMensagem();

                e.Handled = true;
                e.SuppressKeyPress = true; // impede o "beep" padrão
            }
        }


        //----------Evento Click dos Elementos----------
        // Button de Enviar
        private void BtnEnviar_Click(object sender, EventArgs e)
        {
            EnviarMensagem();
        }


        //----------Evento Tick dos Elementos----------
        // Timer do Chat
        private void tmChat_Tick(object sender, EventArgs e)
        {
            MostrarChat();
        }



        //---------------------------------------------Parte de fechar o programa---------------------------------------------
        //----------Evento ativado quando o formulário estiver sendo fechado----------
        private void TelaChat_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Para cancelar o fechamento
            e.Cancel = true;

            // Para pegar as variáveis das Coordenadas do Chat
            int X = this.Location.X;
            int Y = this.Location.Y;

            // Para pegar o valor Anterior das Coordenadas do Chat
            Point ponto = valores.CoordenadaChat;

            // Para verificar se o Chat está perto de onde foi gerado
            if ((ponto.X - 8 < X && X < ponto.X + 8) && (ponto.Y - 8 < Y && Y < ponto.Y + 8))
            {
                // Se sim, reseta o valor Anterior das Coordenadas do Chat
                valores.CoordenadaChat = new Point();
            }
            else
            {
                // Se não, guarda o valor Anterior das Coordenadas do Chat
                valores.CoordenadaChat = new Point(X, Y);
            }

            // Para fechar
            e.Cancel = false;
        }



        //---------------------------------------------Parte de outras funções---------------------------------------------
        //----------Função de Mostrar/Atualizar o Chat----------
        private void MostrarChat()
        {
            try
            {
                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                DataTable dtChat = objBanco.MostraChat(cpfPaciente, Funcionario.Id);

                // Verificar se o Chat é inválido
                if (dtChat.Columns.Count == 1)
                {
                    MessageBox.Show("Reinicie o chat!", "Algum erro ocorreu!!!");
                    return;
                }

                // Verificar se o Chat é válido
                if (dtChat.Columns.Count > 1)
                {
                    // Verifica se o número de mensagens agora é maior que o número de mensangen anterior
                    if (dtChat.Rows.Count > idMensagens.Count)
                    {
                        for (int i = idMensagens.Count; i < dtChat.Rows.Count; i++)
                        {
                            // Registra o ID da Mensagem já Carregada
                            idMensagens.Add(int.Parse(dtChat.Rows[i]["ID_Chat"].ToString()));

                            // Verifica se é Mensagem do Paciente ou Funcionário
                            bool mensagemPaciente = bool.Parse(dtChat.Rows[i]["MsgPaciente"].ToString());
                            string remetente = mensagemPaciente ? nomePaciente : Funcionario.Nome;

                            // Declaração das variáveis Necessárias para Mostrar o Chat
                            DateTime dataNova = DateTime.Parse(dtChat.Rows[i]["Hora_Envio"].ToString());
                            string texto = dtChat.Rows[i]["Mensagem"].ToString();
                            string hora = dataNova.ToString("HH:mm");
                            string data = dataNova.ToString("dd/MM/yyyy");

                            // Declaração de variável usada no Estilo
                            int margem = 5;

                            // Exibe a data somente quando muda o dia
                            if (dataAntiga.Date < dataNova.Date)
                            {
                                dataAntiga = dataNova.Date;

                                // Label da Data
                                Label lblData = new Label();
                                lblData.AutoSize = true;
                                lblData.ForeColor = Color.FromArgb(100, 100, 100);
                                lblData.BackColor = Color.FromArgb(210, 210, 210);
                                lblData.Font = new Font("Inter-Regular", 10, FontStyle.Regular);
                                lblData.Text = (DateTime.Now.Date == dataNova.Date) ? "   Hoje   " : dataNova.ToString("dd/MM/yyyy");
                                lblData.TextAlign = ContentAlignment.MiddleCenter;
                                lblData.Padding = new Padding(2 * margem, margem, 2 * margem, margem);

                                // Painel para centralizar a data
                                Panel pnlData = new Panel();
                                pnlData.AutoSize = true;
                                pnlData.Width = FlowPnlMensagens.Width;
                                pnlData.BackColor = Color.Transparent;
                                pnlData.Margin = new Padding(0, 10, 0, 10);

                                lblData.Left = (pnlData.Width - lblData.Width) / 2;
                                pnlData.Controls.Add(lblData);
                                FlowPnlMensagens.Controls.Add(pnlData);

                                // Arredonda Label da Data
                                EstiloUtils.ArredondarTudo(lblData, 20);
                            }

                            // Painel da mensagem
                            Panel mensagemPnl = new Panel();
                            mensagemPnl.MaximumSize = new Size(FlowPnlMensagens.Width - 40, int.MaxValue);
                            mensagemPnl.BackColor = mensagemPaciente ? Color.FromArgb(255, 255, 255) : Color.FromArgb(0, 26, 110);

                            // Label Nome
                            Label lblNome = new Label();
                            lblNome.Left += margem;
                            lblNome.AutoSize = true;
                            lblNome.MaximumSize = new Size(mensagemPnl.MaximumSize.Width - 15, int.MaxValue);
                            lblNome.ForeColor = mensagemPaciente ? Color.Black : Color.White;
                            lblNome.Font = new Font("Inter-Regular", 12, FontStyle.Bold);
                            lblNome.Text = remetente;

                            // Label Mensagem
                            Label lblMensagem = new Label();
                            lblMensagem.Left += margem;
                            lblMensagem.AutoSize = true;
                            lblMensagem.MaximumSize = new Size(mensagemPnl.MaximumSize.Width - 15, int.MaxValue);
                            lblMensagem.ForeColor = mensagemPaciente ? Color.Black : Color.White;
                            lblMensagem.Font = new Font("Inter-Regular", 12, FontStyle.Regular);
                            lblMensagem.Text = texto;

                            // Label Hora
                            Label lblHora = new Label();
                            lblHora.AutoSize = true;
                            lblHora.MaximumSize = new Size(mensagemPnl.MaximumSize.Width - 15, int.MaxValue);
                            lblHora.ForeColor = mensagemPaciente ? Color.FromArgb(111, 111, 111) : Color.FromArgb(222, 222, 222);
                            lblHora.Font = new Font("Inter-Regular", 10, FontStyle.Regular);
                            lblHora.Text = hora;

                            // Adiciona os Elementos no Painel da Mensagem
                            mensagemPnl.Controls.Add(lblNome);
                            mensagemPnl.Controls.Add(lblMensagem);
                            mensagemPnl.Controls.Add(lblHora);

                            // Cria uma Margem entre os Elementos
                            lblNome.Top += margem;
                            lblMensagem.Top = lblNome.Bottom + 2;
                            lblHora.Top = lblMensagem.Bottom + 2;

                            // Verificar se o Comprimento da Mensagem é maior do que o do Nome
                            // Para atribuir a Comprimento do Painel da Mensagem
                            if (lblMensagem.Width > lblNome.Width)
                            {
                                mensagemPnl.Width = lblMensagem.Width + margem + 3;
                                lblHora.Left = lblMensagem.Width - lblHora.Width;
                            }
                            else
                            {
                                mensagemPnl.Width = lblNome.Width + 2 * margem + 3;
                                lblHora.Left += lblNome.Width - lblHora.Width + margem;
                            }

                            // Atribui a Altura do Painel da Mensagem
                            mensagemPnl.Height = margem + lblNome.Height +
                                                 margem + lblMensagem.Height +
                                                 margem + lblHora.Height + margem;

                            // Painel container pra alinhar esquerda/direita
                            Panel container = new Panel();
                            container.AutoSize = false;
                            container.MaximumSize = new Size(FlowPnlMensagens.Width - 17, int.MaxValue);
                            container.Width = FlowPnlMensagens.Width - 17;
                            container.Height = mensagemPnl.Height;
                            container.Padding = new Padding(0);
                            container.Margin = new Padding(0, 10, 0, 10);

                            // Verifica se é Paciente ou Funcionário
                            if (mensagemPaciente)
                            {
                                // Alinha à esquerda
                                mensagemPnl.Left = 7;
                            }
                            else
                            {
                                // Alinha à direita
                                mensagemPnl.Left = container.Width - mensagemPnl.Width - 7;
                            }

                            // Arredonda Painel da Mensagem
                            EstiloUtils.ArredondarTudo(mensagemPnl, 30);

                            // Adiciona Painel da Mensagem no Container
                            container.Controls.Add(mensagemPnl);

                            // Adiciona Container no Painel das Mensagens
                            FlowPnlMensagens.Controls.Add(container);

                            // Rola automaticamente até a última mensagem
                            FlowPnlMensagens.ScrollControlIntoView(container);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }


        //----------Função de Enviar Mensagem----------
        private void EnviarMensagem()
        {
            try
            {
                // Para Resetar o Fundo do BtnEnviar
                BtnEnviar.Invalidate();

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (string.IsNullOrWhiteSpace(TxtMensagem.Text))
                {
                    TxtMensagem.Focus();
                    return;
                }

                // Declarar a variável da mensagem
                string mensagem = TxtMensagem.Text;

                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                string retornoEnviaMensagem = objBanco.EnviaMensagem(cpfPaciente, Funcionario.Id, mensagem);

                // Verificar se a mensagem foi enviada
                if (retornoEnviaMensagem == "Mensagem enviada com sucesso")
                {
                    // Atualizar o Chat
                    MostrarChat();

                    TxtMensagem.Text = "";
                }

                // Para resetar o TxtMensagem
                TxtMensagem.Refresh();
                TxtMensagem.Focus();
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }
    }
}

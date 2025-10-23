using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    public partial class TelaChat : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        String nomePaciente = "";
        String cpfPaciente = "";
        Valores val = new Valores();
        DateTime dataAntiga = new DateTime();


        // Lista dos Ids das Mensagens
        List<int> idMensagens = new List<int>();



        public TelaChat(String nome_Paciente, String cpf_Paciente)
        {
            InitializeComponent();

            nomePaciente = nome_Paciente;
            cpfPaciente = cpf_Paciente;
        }

        private void TelaChat_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Arredondar o Painel Principal--------------------------------------------
            EstiloUtils.ArredondarTudo(PnlChat, 12);



            EstiloUtils.ArredondarTudo(PicBoxEnviar, 35);
            EstiloUtils.ArredondarTudo(PnlTxtBoxMensagem, 35);


            FonteUtils.AplicarFonte(TxtMensagem, "Inter-Regular", 15f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LstBoxMensagens, "Inter-Regular", 7f, FontStyle.Regular);


            LblNomePaciente.Text = nomePaciente;

            MostrarChat();
            //LblNomePaciente.Text = (val.CoordenadaChat).ToString();
        }

        private void PicBoxEnviar_Paint(object sender, PaintEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(TxtMensagem.Text))
            {
                PicBoxEnviar.BackColor = Color.White;
            }
            else
            {
                PicBoxEnviar.BackColor = Color.FromArgb(0, 255, 0);
            }
        }

        private void PicBoxEnviar_MouseEnter(object sender, EventArgs e)
        {
            //if (string.IsNullOrWhiteSpace(TxtMensagem.Text))
            {
                return;
            }

            //PicBoxEnviar.BackColor = Color.FromArgb(0, 255, 0);
        }

        private void PicBoxEnviar_MouseLeave(object sender, EventArgs e)
        {
            //PicBoxEnviar.BackColor = Color.White;
        }

        private void PicBoxEnviar_Click(object sender, EventArgs e)
        {
            try
            {
                PicBoxEnviar.Invalidate();

                if (string.IsNullOrWhiteSpace(TxtMensagem.Text))
                {
                    TxtMensagem.Focus();
                    return;
                }

                string mensagem = TxtMensagem.Text;

                ClsBanco objBanco = new ClsBanco();
                string retornoEnviaMensagem = objBanco.EnviaMensagem(cpfPaciente, Funcionario.Id, mensagem);

                if (retornoEnviaMensagem == "Mensagem enviada com sucesso")
                {
                    MostrarChat();
                    TxtMensagem.Text = "";
                }
                else
                {
                    TxtMensagem.Focus();
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco", "ATENÇÃO!!!");
            }
        }

        private void TxtMensagem_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                PicBoxEnviar.Invalidate();

                if (e.KeyCode == Keys.Enter)
                {
                    if (string.IsNullOrWhiteSpace(TxtMensagem.Text))
                    {
                        TxtMensagem.Focus();
                        return;
                    }

                    string mensagem = TxtMensagem.Text;

                    ClsBanco objBanco = new ClsBanco();
                    string retornoEnviaMensagem = objBanco.EnviaMensagem(cpfPaciente, Funcionario.Id, mensagem);

                    if (retornoEnviaMensagem == "Mensagem enviada com sucesso")
                    {
                        MostrarChat();
                        TxtMensagem.Text = "";
                    }
                    else
                    {
                        TxtMensagem.Focus();
                    }
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco", "ATENÇÃO!!!");
            }
        }


        private void MostrarChat()
        {
            try
            {
                ClsBanco objBanco = new ClsBanco();
                DataTable dtChat = objBanco.MostraChat(cpfPaciente, Funcionario.Id);

                if (dtChat.Columns.Count == 1)
                {
                    MessageBox.Show("Reinicie o chat", "Algum erro ocorreu!!!");
                    return;
                }

                if (dtChat.Columns.Count > 1)
                {
                    if (dtChat.Rows.Count > idMensagens.Count)
                    {
                        int qtdMensagens = idMensagens.Count;
                        for (int i = qtdMensagens; i < dtChat.Rows.Count; i++)
                        {
                            DateTime dataNova = DateTime.Parse(dtChat.Rows[i]["Hora_Envio"].ToString());

                            idMensagens.Add(int.Parse(dtChat.Rows[i]["ID_Chat"].ToString()));

                            if (dataAntiga.Date < dataNova.Date)
                            {
                                LstBoxMensagens.Items.Add(dataNova.ToString("dd/MM/yyyy"));
                                dataAntiga = dataNova.Date;
                                LstBoxMensagens.Items.Add("");
                            }

                            if (Boolean.Parse(dtChat.Rows[i]["MsgPaciente"].ToString()))
                            {
                                LstBoxMensagens.Items.Add(nomePaciente);
                            }
                            else
                            {
                                LstBoxMensagens.Items.Add(Funcionario.Nome);
                            }
                            LstBoxMensagens.Items.Add(dtChat.Rows[i]["Mensagem"].ToString());
                            LstBoxMensagens.Items.Add(dataNova.ToString("HH:mm"));

                            LstBoxMensagens.Items.Add("");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco", "ATENÇÃO!!!");
            }
        }

        private void tmChat_Tick(object sender, EventArgs e)
        {
            MostrarChat();
        }

        private void TelaChat_FormClosing(object sender, FormClosingEventArgs e)
        {
            e.Cancel = true;
            int X = this.Location.X;
            int Y = this.Location.Y;
            Point ponto = val.CoordenadaChat;

            //LblNomePaciente.Text = (new Point(X, Y)).ToString();
            if ((ponto.X - 8 < X && X < ponto.X + 8) && (ponto.Y - 8 < Y && Y < ponto.Y + 8))
            {
                val.CoordenadaChat = new Point();
            }
            else
            {
                val.CoordenadaChat = new Point(X, Y);
            }
            e.Cancel = false;
        }
    }
}

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
using System.Runtime.InteropServices;
using System.Media;

namespace Automácia
{
    public partial class TelaFuncoesFuncHospital : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Declaração da tela do Chat----------
        private TelaChat objTelaChat;


        //----------Variáveis para criação do Textbox transparente----------
        private const int EM_GETLINECOUNT = 0x00BA;
        private bool bloqueandoTexto = false;
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);


        //----------Parte da Navegação----------
        // Para saber qual botão da navegação está selecionado e mudar no OnPaint de cada um
        String selecionado = "";


        //----------Parte da função de Ver Pacientes----------
        // Para saber se o TxtPesquisar está ou não selecionado e mudar no OnPaint de cada um
        Boolean selecionadoTxtBox = false;

        // Lista dos pacientes
        List<Tuple<string, string>> pacientes = new List<Tuple<string, string>>();

        //----------Parte da função de Emitir Receita----------
        RichTextBoxTransparente TxtDetalhes = new RichTextBoxTransparente();



        public TelaFuncoesFuncHospital()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }



        private void TelaFuncoesFuncHospital_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Arredondar o Painel Principal--------------------------------------------
            EstiloUtils.ArredondarTudo(PnlFuncoes, 12);



            //---------------------------------------------Parte da Navegação--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // Buttons
            FonteUtils.AplicarFonte(BtnVerPacientes, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(BtnEmitirReceita, "Inter-Bold", 16.5f, FontStyle.Bold);

            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarCantos(PnlNavegacao, 12, true, true, false, false);

            // Buttons
            EstiloUtils.ArredondarCantos(BtnVerPacientes, 16, true, false, false, false);
            EstiloUtils.ArredondarCantos(BtnEmitirReceita, 16, false, true, false, false);



            //---------------------------------------------Parte da função de Ver Pacientes--------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtPesquisarCPF, "Inter-Regular", 16f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblHistoricoMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNome, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblVerNomePaciente, "Inter-Regular", 16f, FontStyle.Regular);


            //----------Arredondar os controles----------
            // Panels
            EstiloUtils.ArredondarTudo(PnlConteudoVer, 12);
            EstiloUtils.ArredondarCantos(PnlPesquisarCPF, 15, true, true, false, false);
            EstiloUtils.ArredondarTudo(PnlTxtBoxPesquisarCPF, 15);
            EstiloUtils.ArredondarCantos(PnlVerPacientes, 15, false, false, false, true);
            EstiloUtils.ArredondarCantos(PnlPerfilPaciente, 15, false, false, true, false);

            // PictureBoxs
            EstiloUtils.ArredondarTudo(PicBoxFotoPerfil, 90);



            //---------------------------------------------Parte da função de Emitir Receita---------------------------------------------
            //----------Aplicar a fonte personalizada nos controles----------
            // TextBoxs
            FonteUtils.AplicarFonte(TxtCPFPaciente, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtSenha, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtMedicamento, "Inter-Regular", 20f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblCPFPaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDataValidade, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblMedicamento, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDetalhes, "Inter-Bold", 16.5f, FontStyle.Bold);

            // ComboBox
            FonteUtils.AplicarFonte(CmBoxLimitesBaixas, "Inter-Regular", 18f, FontStyle.Regular);

            // Buttons
            FonteUtils.AplicarFonte(BtnEmitir, "Inter-Medium", 22f, FontStyle.Regular);


            //----------Criar o textbox com fundo transparente----------
            TxtDetalhes.Size = PnlTxtBoxDetalhes.Size;
            TxtDetalhes.Font = new Font("Inter-Regular", 20);
            TxtDetalhes.Location = new Point(0, 0);
            TxtDetalhes.ScrollBars = RichTextBoxScrollBars.None;
            TxtDetalhes.Name = "TxtDetalhes";
            TxtDetalhes.KeyDown += (s, f) =>{ RedirecionarProximo_KeyDown(s, f); };
            TxtDetalhes.TextChanged += (s, f) =>
            {
                if (bloqueandoTexto) return;

                int linhaRenderizada = SendMessage(TxtDetalhes.Handle, EM_GETLINECOUNT, 0, 0);

                if (linhaRenderizada > 2)
                {
                    bloqueandoTexto = true;

                    // Remove o último caractere que causou excesso
                    int pos = TxtDetalhes.SelectionStart;
                    if (pos > 0)
                    {
                        TxtDetalhes.Text = TxtDetalhes.Text.Remove(pos - 1, 1);
                        TxtDetalhes.SelectionStart = pos - 1;
                    }

                    bloqueandoTexto = false;
                }
            };

            PnlTxtBoxDetalhes.Controls.Add(TxtDetalhes);


            //---------- Definir data Inicial do DateTimePicker ----------
            DataValidade.Value = DateTime.Now;


            //---------- Definir Index Inicial do ComboBox ----------
            CmBoxLimitesBaixas.SelectedIndex = 0;


            //----------Arredondar os controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnEmitir, 30);
        }




        //---------------------------------------------Parte dos botões de cima---------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo da parte de navegação
        private void PnlNavegacao_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaArredondada(e, sender, 2, 12, true, true, false, false, Color.Black);
        }

        // Fundo do Button de Ver Pacientes
        private void BtnVerPacientes_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            if (selecionado == "VerPacientes")
            {
                EstiloUtils.DesenharBordaSemBase(e, sender, 4, 10, Color.Black, true);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }

        // Fundo do Button de Emitir Receitar
        private void BtnEmitirReceita_Paint(object sender, PaintEventArgs e)
        {
            if (selecionado == "EmitirReceita")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, true, false, true, true, Color.Black);
            }
            else if (selecionado != "")
            {
                EstiloUtils.DesenharBorda(e, sender, 4, false, true, false, false, Color.Black);
            }
        }


        //----------Evento Click dos Buttons----------
        // Button de Ver Pacientes
        private void BtnVerPacientes_Click(object sender, EventArgs e)
        {
            selecionado = "VerPacientes";

            PnlFuncaoVerPacientes.Visible = true;
            PnlFuncaoEmitirReceita.Visible = false;

            BtnVerPacientes.ForeColor = Color.Black;
            BtnEmitirReceita.ForeColor = Color.Gray;

            BtnVerPacientes.Invalidate();
            BtnEmitirReceita.Invalidate();
        }

        // Button de Emitir Receita
        private void BtnEmitirReceita_Click(object sender, EventArgs e)
        {
            selecionado = "EmitirReceita";

            PnlFuncaoVerPacientes.Visible = false;
            PnlFuncaoEmitirReceita.Visible = true;

            BtnVerPacientes.ForeColor = Color.Gray;
            BtnEmitirReceita.ForeColor = Color.Black;

            BtnVerPacientes.Invalidate();
            BtnEmitirReceita.Invalidate();
        }




        //---------------------------------------------Os fundos de cada função---------------------------------------------
        // Fundo da função de Ver Pacientes
        private void PnlFuncaoVerPacientes_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }

        // Fundo da função de Emitir Receita
        private void PnlFuncaoEmitirReceita_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            EstiloUtils.DesenharBordaArredondada(e, sender, 6, 12, false, false, true, true, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 6, true, false, false, false, controle.BackColor);
        }




        //---------------------------------------------Função de Ver Pacientes---------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo de Ver Pacientes
        private void PnlConteudoVer_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 3, 12, Color.Black);
        }

        // Fundo de Pesquisar Nome
        private void PnlPesquisarNome_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.Black);
        }

        // Fundo de Ver Pacientes
        private void PnlVerPacientes_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }

        // Fundo do Histórico Médico
        private void PnlHistoricoMedico_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, true, false, Color.Black);
            EstiloUtils.DesenharBorda(e, sender, 3, false, false, false, true, Color.FromArgb(64, 0, 0, 0));
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);

        }

        // Fundo do Perfil
        private void PnlPerfilPaciente_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 1, true, false, false, false, Color.Black);
        }


        //----------Função de Pesquisar Nome----------
        // Fundo do TxtBox de PesquisarNome
        private void PnlTxtBoxPesquisarNome_Paint(object sender, PaintEventArgs e)
        {
            if (selecionadoTxtBox)
            {
                EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 12, ColorTranslator.FromHtml("#00B2FF"));
            }
            else
            {
                EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 12, Color.Black);
            }
        }

        // Evento Enter do TxtBox PesquisarNome
        private void TxtPesquisarNome_Enter(object sender, EventArgs e)
        {
            selecionadoTxtBox = true;
            PnlTxtBoxPesquisarCPF.Invalidate();
        }

        // Evento Leave do TxtBox PesquisarNome
        private void TxtPesquisarNome_Leave(object sender, EventArgs e)
        {
            selecionadoTxtBox = false;
            PnlTxtBoxPesquisarCPF.Invalidate();
        }

        // Evento KeyDown do TxtBox PesquisarNome
        private void TxtPesquisarCPF_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Para detectar se foi pressionado Enter para iniciar a pesquisa
                if (e.KeyCode == Keys.Enter)
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    if (string.IsNullOrWhiteSpace(TxtPesquisarCPF.Text))
                    {
                        TxtPesquisarCPF.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Preencha o CPF do paciente antes de pesquisar!", "ATENÇÃO!!!");
                        return;
                    }

                    // Pega o CPF do Paciente
                    string cpfPaciente = TxtPesquisarCPF.Text;

                    // Verificar se o Paciente pesquisado já não foi Pesquisado antes
                    foreach (var paciente in pacientes)
                    {
                        if (paciente.Item1 == cpfPaciente)
                        {
                            TxtPesquisarCPF.Focus();
                            SystemSounds.Beep.Play(); // cria o "beep" padrão
                            MessageBox.Show("Paciente já buscado anteriormente!", "ATENÇÃO!!!");
                            return;
                        }
                    }

                    // Declaração da Classe que pega do Banco e do DataTable necessário
                    ClsBanco objBanco = new ClsBanco();
                    DataTable dtChat = objBanco.MostraChat(cpfPaciente, Funcionario.Id);

                    // Verificar se o CPF é Inválido
                    if (dtChat.Columns.Count == 1)
                    {
                        TxtPesquisarCPF.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Verifique o CPF inserido!", "Paciente não identificado!!!");
                        return;
                    }

                    // Verificar se o CPF é Válido
                    if (dtChat.Columns.Count > 1)
                    {
                        // Declara a Variável do Nome do Paciente
                        string nomePaciente = dtChat.Rows[0]["Nome_Paciente"].ToString();

                        // Mostrar Perfil do Paciente
                        LblVerNome.Visible = true;
                        PicBoxFotoPerfil.Visible = true;
                        LblVerNomePaciente.Visible = true;
                        WebHistoricoMedico.Visible = true;
                        LblVerNomePaciente.Text = nomePaciente;

                        // Inserir dados do Novo Paciente
                        pacientes.Add(Tuple.Create(cpfPaciente, nomePaciente));

                        GerarPacientes();

                        // Resetar o TextBox da Pesquisa
                        TxtPesquisarCPF.Text = "";
                        selecionadoTxtBox = false;
                        PnlTxtBoxPesquisarCPF.Invalidate();
                    }
                    else
                    {
                        TxtPesquisarCPF.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Verifique o CPF inserido!", "Paciente não identificado!!!");
                    }
                    e.Handled = true;
                    e.SuppressKeyPress = true; // impede o "beep" padrão
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }


        //----------Função de Histórico Médico----------
        // Fundo do Label do HistóricoMédico
        private void LblHistoricoMedico_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 3, false, true, false, false, Color.FromArgb(64, 0, 0, 0));
        }


        //----------Função de Perfil do Paciente----------
        // Fundo do PicBox do Perfil do Paciente
        private void PicBoxFotoPerfil_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 170, Color.Black);
        }

       

        //---------------------------------------------Função de Emitir Receita---------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo do TxtBox do CPF do Paciente
        private void PnlTxtBoxCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TxtBox da Senha do Médico
        private void PnlTxtBoxSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TxtBox do Medicamento
        private void PnlTxtBoxMedicamento_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do TxtBox dos Detalhes
        private void PnlTxtBoxDetalhes_Paint(object sender, PaintEventArgs e)
        {
            int espacamento = 32;
            using (Pen caneta = new Pen(Color.Black, 2))
            {
                for (int y = espacamento; y < PnlTxtBoxDetalhes.Height; y += espacamento)
                {
                    e.Graphics.DrawLine(caneta, 0, y, PnlTxtBoxDetalhes.Width, y);
                }
            }
        }

        // Fundo do Button de Emitir Receita
        private void BtnEmitir_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }


        //----------Evento KeyDown dos Elementos----------
        // Para redirecionar para o próximo elemento depois de já preenchido esse espaço
        private void RedirecionarProximo_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Verificar se a tecla apertada foi Enter
                if (e.KeyCode == Keys.Enter)
                {
                    Control controle = sender as Control;

                    switch (controle.Name)
                    {
                        case "TxtCPFPaciente":
                            DataValidade.Focus();
                            break;
                        case "DataValidade":
                            TxtSenha.Focus();
                            break;
                        case "TxtSenha":
                            CmBoxLimitesBaixas.Focus();
                            break;
                        case "CmBoxLimitesBaixas":
                            TxtMedicamento.Focus();
                            break;
                        case "TxtMedicamento":
                            TxtDetalhes.Focus();
                            break;
                        case "TxtDetalhes":
                            BtnEmitir.Focus();
                            break;
                        case "BtnEmitir":
                            EmitirReceita();
                            break;
                        default:
                            TxtCPFPaciente.Focus();
                            break;
                    }
                    e.Handled = true;
                    e.SuppressKeyPress = true; // impede o "beep" padrão
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Evento KeyPress dos Elementos----------
        // Para permitir apenas números e teclas de controle (como Backspace)
        private void Numerico_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        // Para proibir a digitação no elemento
        private void Proibir_KeyPress(object sender, KeyPressEventArgs e)
        {
           e.Handled = false;
          
        }


        //----------Evento Click dos Elementos----------
        // Button de Emitir Receita
        private void BtnEmitir_Click(object sender, EventArgs e)
        {
            EmitirReceita();
        }



        //---------------------------------------------Parte de fechar o programa---------------------------------------------
        // Evento ativado quando o formulário estiver sendo fechado
        private void TelaFuncoesFuncHospital_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!Sessao.saindo)
            {
                // Confirmação para ver se o programa realmente vai ser fechado
                var confirmar = MessageBox.Show("Deseja realmente sair?", "Sair", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (confirmar == DialogResult.Yes)
                {
                    // Para fechar a Aplicação
                    Sessao.saindo = true;
                    Application.Exit();
                }
                else
                {
                    // Para cancelar o fechamento
                    e.Cancel = true;
                }
            }
        }

        // Evento ativado quando o formulário for fechado
        private void TelaFuncoesFuncHospital_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }



        //---------------------------------------------Parte de outras funções---------------------------------------------
        //----------Função para Mostrar os Pacientes----------
        private void GerarPacientes()
        {
            try
            {
                // Limpa os botões antigos, se houver
                PnlVerPacientes.Controls.Clear();

                int larguraBotao = PnlVerPacientes.Width;
                if (pacientes.Count > 9)
                {
                    // ajuste para scroll
                    larguraBotao -= SystemInformation.VerticalScrollBarWidth;
                }

                for (int i = 0; i < pacientes.Count; i++)
                {
                    //Criar Button
                    Button botao = new Button();
                    Control controle = botao as Control;
                    // Diminuir Nome do Paciente
                    if (pacientes[i].Item2.Count() > 15)
                    {
                        botao.Text = $"{pacientes[i].Item2.Substring(0, 15)}";
                    }
                    else
                    {
                        botao.Text = $"{pacientes[i].Item2}";
                    }
                    botao.Width = larguraBotao;
                    botao.Height = 44;
                    botao.Left = 0;
                    botao.Top = i * 44;
                    botao.Name = $"{pacientes[i].Item1}";

                    // Estilo flat sem borda padrão
                    botao.FlatStyle = FlatStyle.Flat;
                    botao.FlatAppearance.BorderSize = 0;
                    botao.BackColor = Color.White;
                    botao.ForeColor = Color.Black;

                    // Borda desenhada à mão
                    if (pacientes.Count > 9 && i == pacientes.Count - 1)
                    {
                        botao.Paint += (s, f) =>
                        {
                            EstiloUtils.DesenharBorda(f, s, 2, false, false, false, true, Color.Black);
                        };
                    }
                    else
                    {
                        botao.Paint += (s, f) =>
                        {
                            EstiloUtils.DesenharBorda(f, s, 2, false, true, false, true, Color.Black);
                        };
                    }

                    // Clique do botão
                    botao.Click  += async (s, f) =>
                    {
                        //---Para Mostrar o Perfil do Paciente---
                        LblVerNome.Visible = true;
                        PicBoxFotoPerfil.Visible = true;
                        LblVerNomePaciente.Visible = true;
                        WebHistoricoMedico.Visible = true;
                        LblVerNomePaciente.Text = botao.Text;
                        LblVerCPFPaciente.Text = botao.Name;


                        //---Para Gerar o Chat---
                        // Variável sobre as Coordenadas do Forms
                        Valores valores = new Valores();

                        // Criar o Chat do lado da Tela Principal
                        Point ponto = new Point(this.Location.X + this.Width - 16, this.Location.Y);

                        // Para verificar já existe um Chat aberto, antes de abrir um novo
                        if (objTelaChat == null || objTelaChat.IsDisposed)
                        {
                        }
                        else
                        {
                            objTelaChat.Close();
                        }

                        // Para verificar se as Coordenadas do Chat anterior não são Vazias
                        if (valores.CoordenadaChat != new Point())
                        {
                            // Para pegar o valor Anterior das Coordenadas do Chat
                            ponto = valores.CoordenadaChat;

                            // Registra o Valor das Coordenadas igual ao valor anterior do ponto
                            valores.CoordenadaChat = new Point(this.Location.X + this.Width - 16, this.Location.Y);
                        }
                        else
                        {
                            // Registra o Valor das Coordenadas igual ao ponto
                            valores.CoordenadaChat = ponto;
                        }

                        // Cria o Forms do Chat 
                        objTelaChat = new TelaChat(botao.Text, botao.Name);
                        objTelaChat.StartPosition = FormStartPosition.Manual;
                        objTelaChat.Location = ponto;
                        objTelaChat.Show();


                        /* Para teste
                        //---Para Ver Historico Médico---
                        // Declaração da Classe que pega do Banco e do DataTable necessário
                        byte[] dadosArquivo = null;
                        using (OpenFileDialog dialog = new OpenFileDialog())
                        {
                            dialog.Title = "Selecione um arquivo";
                            dialog.Filter = "Todos os arquivos (*.*)|*.*";
                            dialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

                            if (dialog.ShowDialog() == DialogResult.OK)
                            {
                                string caminho = dialog.FileName;
                                dadosArquivo = await FileUtils.ArquivoParaBinarioAssinc(caminho);
                            }
                        }

                        // Declaração da Classe que pega do Banco e do DataTable necessário
                        ClsBanco objBanco = new ClsBanco();
                        string retornoCadastro = objBanco.CadastraHistorico(botao.Name, "Teste&951", dadosArquivo);

                        // Verificar se foi Válido a Inserção do Historico
                        if (retornoCadastro == "Histórico médico inserido com sucesso")
                        {
                            
                        }
                        */

                        // Declaração da Classe que pega do Banco e do DataTable necessário
                        ClsBanco objBanco = new ClsBanco();
                        DataTable dtHistorico = objBanco.ConsultaHistorico(botao.Name);

                        // Verificar se foi Válido a Consulta do Historico
                        if (dtHistorico.Columns.Count > 1)
                        {
                            string caminhoPdf = $@"C:\Users\{System.Environment.UserName}\Automacia\HistoricoMedico-{botao.Text}.pdf";
                            byte[] dadosArquivo = (byte[])dtHistorico.Rows[0]["Registro_Medico"];
                            await FileUtils.BinarioParaArquivoAssinc(dadosArquivo, caminhoPdf);

                            WebHistoricoMedico.Visible = true;
                            WebHistoricoMedico.Navigate(caminhoPdf);
                        }

                    };

                    // Aplicar fonte personalizada nos botões
                    FonteUtils.AplicarFonte(controle, "Inter-Regular", 16.501f, FontStyle.Regular);

                    // Adicionar button no panel
                    PnlVerPacientes.Controls.Add(botao);
                }
                // Deixa o Button do Paciente em Focus()
                PnlVerPacientes.Controls[pacientes.Count - 1].Focus();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Função de Emitir Receita----------
        private void EmitirReceita()
        {
            try
            {
                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                foreach (var controle in new[] { TxtCPFPaciente, TxtSenha, TxtMedicamento })
                {
                    if (string.IsNullOrWhiteSpace(controle.Text))
                    {
                        controle.Focus();
                        SystemSounds.Beep.Play();
                        MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                        return;
                    }
                }

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (string.IsNullOrWhiteSpace(DataValidade.Text))
                {
                    DataValidade.Focus();
                    SystemSounds.Beep.Play();
                    MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                    return;
                }

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (string.IsNullOrWhiteSpace(TxtDetalhes.Text))
                {
                    TxtDetalhes.Focus();
                    SystemSounds.Beep.Play();
                    MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                    return;
                }

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (string.IsNullOrWhiteSpace(CmBoxLimitesBaixas.Text))
                {
                    SystemSounds.Beep.Play();
                    CmBoxLimitesBaixas.Focus();
                    MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                    return;
                }

                // Declaração das variáveis mais comuns
                string cpfReceita = TxtCPFPaciente.Text;
                string senha = TxtSenha.Text;
                DateTime dataValidade = DateTime.Parse(DataValidade.Text);
                string medicamento = TxtMedicamento.Text;
                string detalhes = TxtDetalhes.Text;
                int limiteBaixas = int.Parse(CmBoxLimitesBaixas.Text);

                // Veriica se a Data de Validade é menor que a Data de Hoje
                if (dataValidade.Date < DateTime.Now.Date)
                {
                    DataValidade.Focus();
                    SystemSounds.Beep.Play();
                    MessageBox.Show("Data Inválida!", "ATENÇÃO!!!");
                    return;
                }

                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                string retornoEmitirReceita = objBanco.EmitirReceita(Funcionario.Id, Funcionario.IdTipo, senha, dataValidade, cpfReceita, medicamento, detalhes, limiteBaixas);

                // Verifica se a Receita foi Criada
                if (retornoEmitirReceita == "Receita criada com sucesso")
                {
                    TxtCPFPaciente.Text = "";
                    TxtCPFPaciente.Focus();
                    DataValidade.Value = DateTime.Now.Date;
                    TxtSenha.Text = "";
                    CmBoxLimitesBaixas.SelectedIndex = 0;
                    TxtMedicamento.Text = "";
                    TxtDetalhes.Text = "";
                    MessageBox.Show(retornoEmitirReceita+ "!", "Receita Emitida!!!");
                }
                else
                {
                    TxtCPFPaciente.Focus();
                    SystemSounds.Beep.Play();
                    MessageBox.Show("Dados inválidos!", "Receita não Emitida!!!");
                }
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
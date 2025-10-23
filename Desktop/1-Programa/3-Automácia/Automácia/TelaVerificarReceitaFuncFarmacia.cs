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
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Declaração de itens necessários para as receitas----------
        static List<int> idReceitasValidas = new List<int> { };
        static int qtdReceitasValidas = 0;
        static Receita receita = null;
        DataTable dtReceita = null;
        


        public TelaVerificarReceitaFuncFarmacia()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }



        private void TelaVerificarReceitaFuncFarmacia_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Parte de Verificar Receita--------------------------------------------
            //----------Arredondar Painel Principal----------
            EstiloUtils.ArredondarTudo(PnlVerificarReceita, 15);


            //----------Arredondar controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnAnterior, 30);
            EstiloUtils.ArredondarTudo(BtnProxima, 30);

            EstiloUtils.ArredondarTudo(BtnPesquisar, 30);
            EstiloUtils.ArredondarCantos(BtnCancelar, 30, false, true, true, false);


            //----------Aplicar a fonte personalizada nos controles----------
            // Textboxs
            FonteUtils.AplicarFonte(TxtCPFReceita, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtSenha, "Inter-Regular", 16.5f, FontStyle.Regular);

            // Labels 1 - Títulos
            FonteUtils.AplicarFonte(LblVerificarReceita, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNumeroReceita, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblCPFPaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNomeCompletoDoPaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblUso, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblIDMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNomeMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblLimiteBaixas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblBaixas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDataDeValidade, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-Bold", 16.5f, FontStyle.Bold);
            
            // Labels 2 - Resultados Válidos
            FonteUtils.AplicarFonte(LblExibirNomeCompletoDoPaciente, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblMedicamentos, "Inter-Regular", 13f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirIDMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirNomeMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirLimiteBaixas, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirBaixas, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirDataValidade, "Inter-Regular", 16.5f, FontStyle.Regular);

            // Labels 3 - Resultados Inválidos
            FonteUtils.AplicarFonte(LblReceitaInvalida, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblMotivoReceitaInvalida, "Inter-Regular", 16.5f, FontStyle.Regular);

            // Buttons
            FonteUtils.AplicarFonte(BtnPesquisar, "Inter-Medium", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnAnterior, "Inter-Medium", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnProxima, "Inter-Medium", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(BtnCancelar, "Inter-Medium", 16.5f, FontStyle.Regular);


            //----------Reiniciar Tela para retirar resultados anteriores----------
            ReiniciarTela();
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

        // Fundo do Panel de Verificar Receita
        private void PnlVerificarReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 5, 12, Color.Black);
        }

        // Fundo do Label de Verificar Receita
        private void LblVerificarReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 5, false, true, false, false, Color.Black);
        }

        // Fundo do Panel do TextBox do CPF
        private void PnlTxtBoxCPFReceita_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do Panel do TextBox da Senha
        private void PnlTxtBoxSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do Button de Voltar
        private void BtnAnterior_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 3, 28, Color.Black);
        }

        // Fundo do Button de Avançar
        private void BtnProxima_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 3, 28, Color.Black);
        }

        // Fundo do Button de Pesquisar
        private void BtnPesquisar_Paint(object sender, PaintEventArgs e)
        {
            Control controle = sender as Control;
            if (controle.Text.Equals("Registrar Uso"))
            {
                EstiloUtils.DesenharBordaArredondada(e, sender, 2, 28, true, false, false, true, Color.Black);
            }
            else
            {
                EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
            }
        }

        // Fundo do Button de Cancelar
        private void BtnCancelar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaArredondada(e, sender, 2, 28, false, true, true, false, Color.Black);
        }


        //----------Evento MouseEnter dos Elementos----------
        // Para mudar fundo do Button quando o mouse fica em cima
        private void BtnCancelar_MouseEnter(object sender, EventArgs e)
        {
            BtnCancelar.ForeColor = Color.White;
            BtnCancelar.BackColor = Color.Red;
        }


        //----------Evento MouseLeave dos Elementos----------
        // Para mudar fundo do Button quando o mouse sai de cima
        private void BtnCancelar_MouseLeave(object sender, EventArgs e)
        {
            BtnCancelar.ForeColor = Color.Black;
            BtnCancelar.BackColor = Color.White;
        }


        //----------Evento KeyDown dos Elementos----------
        // Para redirecionar para o próximo elemento depois de já preenchido esse espaço
        private void TxtCPFReceita_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Verificar se a tecla apertada foi Enter
                if (e.KeyCode == Keys.Enter)
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    if (string.IsNullOrWhiteSpace(TxtCPFReceita.Text))
                    {
                        TxtCPFReceita.Focus();
                        MessageBox.Show("Digite o CPF da Receita antes!", "ATENÇÃO!!!");
                    }
                    else
                    {
                        // Verificar se já foi pesquisado receita(s)
                        if (BtnPesquisar.Text == "Registrar Uso")
                        {
                            TxtSenha.Focus();
                        }
                        else if (BtnPesquisar.Text == "Pesquisar")
                        {
                            // Declaração das variáveis mais comuns
                            string CPFReceita = TxtCPFReceita.Text;

                            // Atribuição da Classe que pega do Banco e do DataTable necessário
                            ClsBanco objBanco = new ClsBanco();
                            dtReceita = objBanco.ConsultaReceita(CPFReceita);

                            // Verificar se a pesquisa da Receita deu errado
                            if (dtReceita.Columns.Count == 1)
                            {
                                PnlInformacoes.Visible = false;
                                PnlResultadoVerificacao.Visible = true;
                                LblMotivoReceitaInvalida.Text = "Receita não Encontrada";
                                return;
                            }

                            // Verificar se a pesquisa da Receita deu certo
                            if (dtReceita.Columns.Count > 1)
                            {
                                // Declaração das variáveis mais comuns
                                int i = 0;
                                qtdReceitasValidas = 0;

                                // Limpar List com as Receitas validas
                                idReceitasValidas.Clear();

                                // Verificar cada Receita para ver se é válida
                                foreach (DataRow linha in dtReceita.Rows)
                                {
                                    if (Boolean.Parse(linha["Valido"].ToString()))
                                    {
                                        idReceitasValidas.Add(i);
                                        qtdReceitasValidas++;
                                    }
                                    i++;
                                }

                                // Verificar se tem no mínimo uma Receita Válida
                                if (qtdReceitasValidas > 0)
                                {
                                    // Mostrar Receita na Tela
                                    MostrarReceita(idReceitasValidas[0]);

                                }
                                else if (qtdReceitasValidas == 0)
                                {
                                    PnlInformacoes.Visible = false;
                                    PnlResultadoVerificacao.Visible = true;
                                    LblMotivoReceitaInvalida.Text = "Receita não Encontrada";
                                }
                            }

                            // Verificar se tem mais de uma Receita Válida
                            if (qtdReceitasValidas > 1)
                            {
                                // Mostrar Button de Avançar
                                BtnProxima.Visible = true;
                                BtnProxima.Enabled = true;

                                // Mostrar Número da Receita
                                LblNumeroReceita.Visible = true;
                                LblNumeroReceita.Text = "1";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        // Para redirecionar para o próximo elemento depois de já preenchido esse espaço
        private void TxtSenha_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Verificar se a tecla apertada foi Enter
                if (e.KeyCode == Keys.Enter)
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    if (string.IsNullOrWhiteSpace(TxtCPFReceita.Text))
                    {
                        TxtCPFReceita.Focus();
                        MessageBox.Show("Digite a sua senha antes!", "Baixa não Sucedida");
                    }
                    else
                    {
                        // Verificar se já foi pesquisado receita(s)
                        if (BtnPesquisar.Text == "Registrar Uso")
                        {
                            // Declaração das variáveis mais comuns
                            string senha = TxtSenha.Text;

                            // Atribuição da Classe que pega do Banco e do resultado necessário
                            ClsBanco objBanco = new ClsBanco();
                            string retornoBaixa = objBanco.RegistrarUso(Funcionario.Id, senha, receita.IdPaciente, receita.Id);

                            // Verificar se a baixa deu certo
                            if (retornoBaixa == "Baixa registrada com sucesso")
                            {
                                // Reiniciar Tela para retirar resultados anteriores
                                ReiniciarTela();

                                // Deixar o TextBox do CPF em Focus
                                TxtCPFReceita.Focus();
                                MessageBox.Show("Baixa registrada com sucesso", "Uso Registrado!");
                            }
                            else
                            {
                                // Deixar o TextBox da Senha em Focus
                                TxtSenha.Focus();
                                MessageBox.Show("Informações inválidas", "Baixa não Sucedida");
                            }
                        }
                        else if (BtnPesquisar.Text == "Pesquisar")
                        {
                            // Reiniciar Tela para retirar resultados anteriores
                            ReiniciarTela();

                            // Deixar o TextBox dp CPF em Focus
                            TxtCPFReceita.Focus();
                        }
                    }
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


        //----------Evento Click dos Elementos----------
        // Button de Voltar
        private void BtnAnterior_Click(object sender, EventArgs e)
        {
            try
            {
                // Verificar se tem mais de uma receita para voltar
                if (qtdReceitasValidas > 1)
                {
                    // Pegar o número da receita
                    int idReceita = int.Parse(LblNumeroReceita.Text);

                    // Verificar se existe a receita anterior
                    if (1 < idReceita && idReceita <= qtdReceitasValidas)
                    {
                        // Alterar número da receita
                        LblNumeroReceita.Text = (idReceita - 1).ToString();

                        // Mostrar Receita na Tela
                        MostrarReceita(idReceitasValidas[idReceita - 2]);

                        // Deixar visível e habilitado o Button de Avançar
                        BtnProxima.Visible = true;
                        BtnProxima.Enabled = true;

                        // Verificar se é possível voltar
                        if (idReceita == 2)
                        {
                            // Deixar invisível e desabilitado o Button de Voltar
                            BtnAnterior.Visible = false;
                            BtnAnterior.Enabled = false;
                        }
                    }
                    else
                    {
                        // Deixar invisível e desabilitado o Button de Voltar
                        BtnAnterior.Visible = false;
                        BtnAnterior.Enabled = false;
                    }
                }
                else
                {
                    // Deixar invisível e desabilitado o Button de Avançar
                    BtnProxima.Visible = false;
                    BtnProxima.Enabled = false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        // Button de Avançar
        private void BtnProxima_Click(object sender, EventArgs e)
        {
            try
            {
                // Verificar se tem mais de uma receita para avançar
                if (qtdReceitasValidas > 1)
                {
                    // Pegar o número da receita
                    int idReceita = int.Parse(LblNumeroReceita.Text);

                    // Verificar se existe a próxima receita
                    if (1 <= idReceita && idReceita < qtdReceitasValidas)
                    {
                        // Alterar número da receita
                        LblNumeroReceita.Text = (idReceita + 1).ToString();

                        // Mostrar Receita na Tela
                        MostrarReceita(idReceitasValidas[idReceita]);

                        // Deixar visível e habilitado o Button de Voltar
                        BtnAnterior.Visible = true;
                        BtnAnterior.Enabled = true;

                        // Verificar se é possível avançar
                        if (idReceita + 1 == qtdReceitasValidas)
                        {
                            // Deixar invisível e desabilitado o Button de Avançar
                            BtnProxima.Visible = false;
                            BtnProxima.Enabled = false;
                        }
                    }
                    else
                    {
                        // Deixar invisível e desabilitado o Button de Avançar
                        BtnProxima.Visible = false;
                        BtnProxima.Enabled = false;
                    }
                }
                else
                {
                    // Deixar invisível e desabilitado o Button de Avançar
                    BtnProxima.Visible = false;
                    BtnProxima.Enabled = false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        // Button de Pesquisar
        private void BtnPesquisar_Click(object sender, EventArgs e)
        {
            try
            {
                // Declaração da Classe que pega do Banco e do resultado necessário
                ClsBanco objBanco = new ClsBanco();
                string retornoAtualiza = objBanco.AtualizaReceita();

                // Verificar se já foi pesquisado receita(s)
                if (BtnPesquisar.Text == "Registrar Uso")
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    if (String.IsNullOrEmpty(TxtSenha.Text))
                    {
                        TxtSenha.Focus();
                        MessageBox.Show("Digite a sua senha antes!", "Baixa não Sucedida");
                        return;
                    }

                    // Declaração das variáveis mais comuns
                    string senha = TxtSenha.Text;

                    // Atribuição da Classe que pega do Banco e do resultado necessário
                    objBanco = new ClsBanco();
                    string retornoBaixa = objBanco.RegistrarUso(Funcionario.Id, senha, receita.IdPaciente, receita.Id);

                    // Verificar se a baixa deu certo
                    if (retornoBaixa == "Baixa registrada com sucesso")
                    {
                        // Reiniciar Tela para retirar resultados anteriores
                        ReiniciarTela();

                        // Deixar o TextBox do CPF em Focus
                        TxtCPFReceita.Focus();
                        MessageBox.Show("Baixa registrada com sucesso", "Uso Registrado!");
                    }
                    else
                    {
                        // Deixar o TextBox da Senha em Focus
                        TxtSenha.Focus();
                        MessageBox.Show("Informações inválidas", "Baixa não Sucedida");
                    }
                }
                else if(BtnPesquisar.Text == "Pesquisar")
                {
                    // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                    if (String.IsNullOrEmpty(TxtCPFReceita.Text))
                    {
                        TxtCPFReceita.Focus();
                        MessageBox.Show("Digite o CPF da Receita antes!", "ATENÇÃO!!!");
                        return;
                    }

                    // Declaração das variáveis mais comuns
                    string CPFReceita = TxtCPFReceita.Text;

                    // Atribuição da Classe que pega do Banco e do DataTable necessário
                    objBanco = new ClsBanco();
                    dtReceita = objBanco.ConsultaReceita(CPFReceita);

                    // Verificar se a pesquisa da Receita deu errado
                    if (dtReceita.Columns.Count == 1)
                    {
                        PnlInformacoes.Visible = false;
                        PnlResultadoVerificacao.Visible = true;
                        LblMotivoReceitaInvalida.Text = "Receita não Encontrada";
                        return;
                    }

                    // Verificar se a pesquisa da Receita deu certo
                    if (dtReceita.Columns.Count > 1)
                    {
                        // Declaração das variáveis mais comuns
                        int i = 0;
                        qtdReceitasValidas = 0;

                        // Limpar List com as Receitas validas
                        idReceitasValidas.Clear();

                        // Verificar cada Receita para ver se é válida
                        foreach (DataRow linha in dtReceita.Rows)
                        {
                            if (Boolean.Parse(linha["Valido"].ToString()))
                            {
                                idReceitasValidas.Add(i);
                                qtdReceitasValidas++;
                            }
                            i++;
                        }

                        // Verificar se tem no mínimo uma Receita Válida
                        if (qtdReceitasValidas > 0)
                        {
                            // Mostrar Receita na Tela
                            MostrarReceita(idReceitasValidas[0]);

                        }else if (qtdReceitasValidas == 0)
                        {
                            PnlInformacoes.Visible = false;
                            PnlResultadoVerificacao.Visible = true;
                            LblMotivoReceitaInvalida.Text = "Receita não Encontrada";
                        }
                    }

                    // Verificar se tem mais de uma Receita Válida
                    if (qtdReceitasValidas > 1)
                    {
                        // Mostrar Button de Avançar
                        BtnProxima.Visible = true;
                        BtnProxima.Enabled = true;

                        // Mostrar Número da Receita
                        LblNumeroReceita.Visible = true;
                        LblNumeroReceita.Text = "1";
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

        // Button de Cancelar
        private void BtnCancelar_Click(object sender, EventArgs e)
        {
            // Reiniciar Tela para retirar resultados anteriores
            ReiniciarTela();
        }



        //---------------------------------------------Parte de fechar o programa---------------------------------------------
        //----------Evento ativado quando o formulário estiver sendo fechado----------
        private void TelaVerificarReceitaFuncFarmacia_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!Sessao.saindo)
            {
                // Confirmação para ver se o programa realmente vai ser fechado
                var confirmar = MessageBox.Show("Deseja realmente sair?", "Sair", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                // Verificar se o usuário confirmou o fechamento
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


        //----------Evento ativado quando o formulário for fechado----------
        private void TelaVerificarReceitaFuncFarmacia_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }



        //---------------------------------------------Parte de outras funções---------------------------------------------
        //----------Função de Mostrar Receita----------
        private void MostrarReceita(int idReceita)
        {
            // Atribuição da Classe da Receita
            receita = new Receita(dtReceita, idReceita);

            // Verificar se ainda não passou a Data de Validade
            if (receita.DataValidade.Date >= DateTime.Now.Date)
            {
                // Verificar a Receita é Válida 
                if (receita.Valido)
                {
                    // Deixar visível a Panel das informações e invisível a Panel do resultado
                    PnlInformacoes.Visible = true;
                    PnlResultadoVerificacao.Visible = false;

                    // Declaração da Classe que pega do Banco e do DataTable necessário
                    ClsBanco objBanco = new ClsBanco();
                    DataTable dtPacientes = objBanco.ConsultaPacientes();

                    // Verificar cada Paciente para ver se o seu nome
                    foreach (DataRow linha in dtPacientes.Rows)
                    {
                        if (linha["Paciente_F"].ToString().Equals(receita.IdPaciente))
                        {
                            LblExibirNomeCompletoDoPaciente.Text = linha["Nome_Paciente"].ToString();
                        }
                    }

                    // Mostrar os Resultados da Pesquisa
                    LblMedicamentos.Text = receita.Medicamento + " - " + receita.Detalhes;
                    LblExibirIDMedico.Text = receita.IdFuncionario;
                    LblExibirNomeMedico.Text = receita.NomeFuncionario;
                    LblExibirLimiteBaixas.Text = receita.LimitesBaixas.ToString();
                    LblExibirBaixas.Text = receita.Baixas.ToString();
                    LblExibirDataValidade.Text = receita.DataValidade.ToString("dd/MM/yyyy");

                    // Alterar o Button de Pesquisar, readondando, mudando texto e reposicionando o Button 
                    EstiloUtils.ArredondarCantos(BtnPesquisar, 30, true, false, false, true);
                    BtnPesquisar.Text = "Registrar Uso";
                    BtnPesquisar.Left = 99;

                    // Alterar o Button de Cancelar, habilitando, deixando visível e reposicionando o Button
                    BtnCancelar.Enabled = true;
                    BtnCancelar.Visible = true;
                    BtnCancelar.Left = 281;

                    // Deixar o TextBox da Senha em Focus
                    TxtSenha.Focus();
                }
                else
                {
                    // Deixar invisível a Panel das informações e visível a Panel do resultado
                    PnlInformacoes.Visible = false;
                    PnlResultadoVerificacao.Visible = true;

                    // Mostrar o resultado no Label
                    LblMotivoReceitaInvalida.Text = "Receita expirada";
                }
            }
            else
            {
                // Deixar visível a Panel das informações e visível a Panel do resultado
                PnlInformacoes.Visible = false;
                PnlResultadoVerificacao.Visible = true;

                // Mostrar o resultado no Label
                LblMotivoReceitaInvalida.Text = "Receita expirada data";

            }
        }


        //----------Função de Reiniciar Tela----------
        private void ReiniciarTela()
        {
            // Limpar receita
            receita = null;

            // Limpar TextBox do CPF
            TxtCPFReceita.Text = "";

            // Limpar Labels dos Resultados da Pesquisas
            LblExibirNomeCompletoDoPaciente.Text = "";
            LblMedicamentos.Text = "";
            LblExibirIDMedico.Text = "";
            LblExibirNomeMedico.Text = "";
            LblExibirLimiteBaixas.Text = "";
            LblExibirBaixas.Text = "";
            LblExibirDataValidade.Text = "";

            // Limpar TextBox da Senha
            TxtSenha.Text = "";

            // Deixar invisível os Panels que mostram os Resultados
            PnlInformacoes.Visible = false;
            PnlResultadoVerificacao.Visible = false;

            // Deixar invisível e desabilitado os Buttons de Avançar e Voltar
            BtnAnterior.Visible = false;
            BtnAnterior.Enabled = false;
            BtnProxima.Visible = false;
            BtnProxima.Enabled = false;

            // Resetar o Button de Pesquisar, readondando, mudando texto e reposicionando o Button 
            EstiloUtils.ArredondarTudo(BtnPesquisar, 30);
            BtnPesquisar.Text = "Pesquisar";
            BtnPesquisar.Left = 121;

            // Resetar o Button de Cancelar, desabilitando, deixando invisível e reposicionando o Button
            BtnCancelar.Visible = false;
            BtnCancelar.Enabled = false;
            BtnCancelar.Left = 304;
        }
    }
}

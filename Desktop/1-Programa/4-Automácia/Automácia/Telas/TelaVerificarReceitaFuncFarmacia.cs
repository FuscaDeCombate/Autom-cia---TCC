using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Media;
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
        static int idReceita = 0;
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
            FonteUtils.AplicarFonte(LblCPFPaciente, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblNomeCompletoDoMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblUso, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblIDMedico, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblLimiteBaixas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblBaixas, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblDataDeValidade, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-Bold", 16.5f, FontStyle.Bold);

            // Labels 2 - Resultados Válidos
            FonteUtils.AplicarFonte(LblExibirNomeCompletoDoMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblMedicamentos, "Inter-Regular", 13f, FontStyle.Regular);
            FonteUtils.AplicarFonte(LblExibirIDMedico, "Inter-Regular", 16.5f, FontStyle.Regular);
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
        }


        //----------Evento MouseLeave dos Elementos----------
        // Para mudar fundo do Button quando o mouse sai de cima
        private void BtnCancelar_MouseLeave(object sender, EventArgs e)
        {
            BtnCancelar.ForeColor = Color.Black;
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
                    // Verificar se já foi pesquisado receita(s)
                    if (BtnPesquisar.Text == "Registrar Uso")
                    {
                        TxtSenha.Focus();
                    }
                    else if (BtnPesquisar.Text == "Pesquisar")
                    {
                        ConsultarReceita();
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

        // Para redirecionar para o próximo elemento depois de já preenchido esse espaço
        private void TxtSenha_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Verificar se a tecla apertada foi Enter
                if (e.KeyCode == Keys.Enter)
                {
                    // Verificar se já foi pesquisado receita(s)
                    if (BtnPesquisar.Text == "Registrar Uso")
                    {
                        // Para executar depois do evento Keydown, para carregar totalmente o Enter e evitar o "beep" padrão
                        this.BeginInvoke(new Action(() =>
                        {
                            DarBaixa();
                        }));
                    }
                    else if (BtnPesquisar.Text == "Pesquisar")
                    {
                        ReiniciarTela();
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


        //----------Evento Click dos Elementos----------
        // Button de Voltar
        private void BtnAnterior_Click(object sender, EventArgs e)
        {
            try
            {
                // Verificar se tem mais de uma receita para voltar
                if (qtdReceitasValidas > 1)
                {
                    // Verificar se existe a receita anterior
                    if (1 < idReceita && idReceita <= qtdReceitasValidas)
                    {
                        // Alterar número da receita
                        idReceita--;
                        LblVerificarReceita.Text = $"Verificar Receita {idReceita}/{qtdReceitasValidas}";

                        // Mostrar Receita na Tela
                        MostrarReceita(idReceitasValidas[idReceita - 1]);

                        // Mostrar o Button de Avançar
                        DesHabilitarControle(BtnProxima, true);

                        // Verificar se é possível voltar
                        if (idReceita == 1)
                        {
                            // Ocultar o Button de Voltar
                            DesHabilitarControle(BtnAnterior, false);
                        }
                    }
                    else
                    {
                        // Ocultar o Button de Voltar
                        DesHabilitarControle(BtnAnterior, false);
                    }
                }
                else
                {
                    // Ocultar o Button de Avançar
                    DesHabilitarControle(BtnProxima, false);
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
                    // Verificar se existe a próxima receita
                    if (1 <= idReceita && idReceita < qtdReceitasValidas)
                    {
                        // Alterar número da receita
                        idReceita++;
                        LblVerificarReceita.Text = $"Verificar Receita {idReceita}/{qtdReceitasValidas}";

                        // Mostrar Receita na Tela
                        MostrarReceita(idReceitasValidas[idReceita - 1]);

                        // Mostrar o Button de Voltar
                        DesHabilitarControle(BtnAnterior, true);

                        // Verificar se é possível avançar
                        if (idReceita == qtdReceitasValidas)
                        {
                            // Ocultar o Button de Avançar
                            DesHabilitarControle(BtnProxima, false);
                        }
                    }
                    else
                    {
                        // Ocultar o Button de Avançar
                        DesHabilitarControle(BtnProxima, false);
                    }
                }
                else
                {
                    // Ocultar o Button de Avançar
                    DesHabilitarControle(BtnProxima, false);
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
                // Verificar se já foi pesquisado receita(s)
                if (BtnPesquisar.Text == "Registrar Uso")
                {
                    DarBaixa();
                }
                else if (BtnPesquisar.Text == "Pesquisar")
                {
                    ConsultarReceita();
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }

        // Button de Cancelar
        private void BtnCancelar_Click(object sender, EventArgs e)
        {
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
        //----------Função de Dar Baixa----------
        private void DesHabilitarControle(Control controle, bool habilitar)
        {
            try
            {
                controle.Visible = habilitar;
                controle.Enabled = habilitar;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Função de Reiniciar Tela----------
        private void ReiniciarTela()
        {
            try
            {
                // Limpar receita
                receita = null;

                // Limpar TextBox do CPF
                TxtCPFReceita.Text = "";
                LblVerificarReceita.Text = "Verificar Receita";

                // Limpar Labels dos Resultados da Pesquisas
                LblExibirNomeCompletoDoMedico.Text = "";
                LblMedicamentos.Text = "";
                LblExibirIDMedico.Text = "";
                LblExibirLimiteBaixas.Text = "";
                LblExibirBaixas.Text = "";
                LblExibirDataValidade.Text = "";

                // Limpar TextBox da Senha
                TxtSenha.Text = "";

                // Ocultar os Panels que mostram os Resultados
                DesHabilitarControle(PnlInformacoes, false);
                DesHabilitarControle(PnlResultadoVerificacao, false);

                // Ocultar os Buttons de Avançar e Voltar
                DesHabilitarControle(BtnAnterior, false);
                DesHabilitarControle(BtnProxima, false);

                // Resetar o Button de Pesquisar, readondando, mudando texto e reposicionando o Button 
                EstiloUtils.ArredondarTudo(BtnPesquisar, 30);
                BtnPesquisar.Text = "Pesquisar";
                BtnPesquisar.Left = 121;

                // Resetar o Button de Cancelar, Ocultando e Reposicionando o Button
                DesHabilitarControle(BtnCancelar, false);
                BtnCancelar.Left = 304;

                // Para deixar o TextBox do CPF em focus()
                TxtCPFReceita.Focus();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Função de Mostrar Receita----------
        private void MostrarReceita(int idReceita)
        {
            try
            {
                // Atribuição da Classe da Receita
                receita = new Receita(dtReceita, idReceita);

                // Verificar se ainda não passou a Data de Validade
                if (receita.DataValidade.Date >= DateTime.Now.Date)
                {
                    // Verificar a Receita é Válida 
                    if (receita.Valido)
                    {
                        // Mostrar o Panel das Informações e Ocultar o Panel do Resultado
                        DesHabilitarControle(PnlInformacoes, true);
                        DesHabilitarControle(PnlResultadoVerificacao, false);

                        // Mostrar os Resultados da Pesquisa
                        LblExibirNomeCompletoDoMedico.Text = receita.NomeFuncionario;
                        LblMedicamentos.Text = receita.Medicamento + " - " + receita.Detalhes;
                        LblExibirIDMedico.Text = receita.IdFuncionario;
                        LblExibirLimiteBaixas.Text = receita.LimitesBaixas.ToString();
                        LblExibirBaixas.Text = receita.Baixas.ToString();
                        LblExibirDataValidade.Text = receita.DataValidade.ToString("dd/MM/yyyy");

                        // Alterar o Button de Pesquisar, readondando, mudando texto e reposicionando o Button 
                        EstiloUtils.ArredondarCantos(BtnPesquisar, 30, true, false, false, true);
                        BtnPesquisar.Text = "Registrar Uso";
                        BtnPesquisar.Left = 99;

                        // Alterar o Button de Cancelar, Mostrando e Reposicionando o Button
                        DesHabilitarControle(BtnCancelar, true);
                        BtnCancelar.Left = 281;

                        // Deixar o TextBox da Senha em Focus
                        TxtSenha.Focus();
                    }
                    else
                    {
                        TxtCPFReceita.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão

                        // Ocultar o Panel das Informações e Mostrar o Panel do Resultado
                        DesHabilitarControle(PnlInformacoes, false);
                        DesHabilitarControle(PnlResultadoVerificacao, true);

                        // Mostrar o Resultado no Label
                        LblMotivoReceitaInvalida.Text = "Receita expirada";
                    }
                }
                else
                {
                    TxtCPFReceita.Focus();
                    SystemSounds.Beep.Play(); // cria o "beep" padrão

                    // Ocultar o Panel das Informações e Mostrar o Panel do Resultado
                    DesHabilitarControle(PnlInformacoes, false);
                    DesHabilitarControle(PnlResultadoVerificacao, true);

                    // Mostrar o resultado no Label
                    LblMotivoReceitaInvalida.Text = "Receita expirada data";

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Função de Consultar Receita----------
        private void ConsultarReceita()
        {
            try
            {
                // Declaração da Classe que pega do Banco e do resultado necessário
                ClsBanco objBanco = new ClsBanco();
                string retornoAtualiza = objBanco.AtualizaReceita();

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (String.IsNullOrEmpty(TxtCPFReceita.Text))
                {
                    ReiniciarTela();
                    SystemSounds.Beep.Play();
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
                    TxtCPFReceita.Focus();
                    SystemSounds.Beep.Play();
                    DesHabilitarControle(PnlInformacoes, false);
                    DesHabilitarControle(PnlResultadoVerificacao, true);
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
                        idReceita = 1;
                    }
                    else if (qtdReceitasValidas == 0)
                    {
                        TxtCPFReceita.Focus();
                        SystemSounds.Beep.Play();
                        DesHabilitarControle(PnlInformacoes, false);
                        DesHabilitarControle(PnlResultadoVerificacao, true);
                        LblMotivoReceitaInvalida.Text = "Receita não Encontrada";
                    }
                }

                // Verificar se tem mais de uma Receita Válida
                if (qtdReceitasValidas > 1)
                {
                    // Mostrar o Button de Avançar
                    DesHabilitarControle(BtnProxima, true);

                    // Mostrar o Número da Receita
                    LblVerificarReceita.Text = $"Verificar Receita {idReceita}/{qtdReceitasValidas}";
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }


        //----------Função de Dar Baixa----------
        private void DarBaixa()
        {
            try
            {
                // Declaração da Classe que pega do Banco e do resultado necessário
                ClsBanco objBanco = new ClsBanco();
                string retornoAtualiza = objBanco.AtualizaReceita();

                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                if (String.IsNullOrEmpty(TxtSenha.Text))
                {
                    TxtSenha.Focus();
                    SystemSounds.Beep.Play();
                    MessageBox.Show("Digite a sua senha antes!", "Baixa não Sucedida!!!");
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
                    ReiniciarTela();
                    MessageBox.Show("Baixa registrada com sucesso!", "Uso Registrado!!!");
                }
                else
                {
                    TxtSenha.Focus();
                    SystemSounds.Beep.Play();
                    MessageBox.Show("Informações inválidas!", "Baixa não Sucedida!!!");
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

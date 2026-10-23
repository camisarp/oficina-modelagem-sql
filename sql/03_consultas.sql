USE oficina;
-- Data fixa para resultados reproduziveis. Altere se desejar outra referencia.
SET @data_referencia = '2026-10-22';

-- 01. Quais servicos estao cadastrados?
SELECT idServico, Descricao, ValorReferencia FROM Servico ORDER BY Descricao;

-- 02. Quais ordens estao em execucao?
SELECT idOrdemServico, DataPrevista, RelatoCliente FROM OrdemServico WHERE Status = 'Em execucao' ORDER BY DataPrevista;

-- 03. Quais veiculos pertencem a cada cliente?
SELECT c.Nome, v.Placa, v.Marca, v.Modelo FROM Cliente c JOIN Veiculo v ON v.Cliente_idCliente = c.idCliente ORDER BY c.Nome, v.Placa;

-- 04. Quantas ordens cada cliente possui, incluindo quem ainda nao tem ordens?
SELECT c.idCliente, c.Nome, COUNT(os.idOrdemServico) AS QuantidadeOrdens FROM Cliente c LEFT JOIN Veiculo v ON v.Cliente_idCliente = c.idCliente LEFT JOIN OrdemServico os ON os.Veiculo_idVeiculo = v.idVeiculo GROUP BY c.idCliente, c.Nome ORDER BY QuantidadeOrdens DESC, c.idCliente;

-- 05. Quais clientes possuem mais de uma ordem?
SELECT c.idCliente, c.Nome, COUNT(os.idOrdemServico) AS QuantidadeOrdens FROM Cliente c JOIN Veiculo v ON v.Cliente_idCliente = c.idCliente JOIN OrdemServico os ON os.Veiculo_idVeiculo = v.idVeiculo GROUP BY c.idCliente, c.Nome HAVING COUNT(os.idOrdemServico) > 1 ORDER BY QuantidadeOrdens DESC, c.idCliente;

-- 06. Qual o subtotal de cada servico em uma ordem?
SELECT oss.OrdemServico_idOrdemServico AS Ordem, s.Descricao, oss.Quantidade, oss.ValorUnitario, oss.Quantidade * oss.ValorUnitario AS Subtotal FROM ItemServico oss JOIN Servico s ON s.idServico = oss.Servico_idServico ORDER BY Ordem, s.idServico;

-- 07. Qual o total de servicos e pecas de cada ordem, inclusive ordens sem itens?
SELECT os.idOrdemServico, os.Status, t.TotalServicos, t.TotalPecas, t.TotalOrdem FROM OrdemServico os JOIN vw_TotalOrdemServico t ON t.idOrdemServico = os.idOrdemServico ORDER BY t.TotalOrdem DESC, os.idOrdemServico;

-- 08. Quais clientes somam mais de R$ 600 em ordens concluidas?
SELECT c.idCliente, c.Nome, SUM(t.TotalOrdem) AS ValorOrdensConcluidas FROM Cliente c JOIN Veiculo v ON v.Cliente_idCliente = c.idCliente JOIN OrdemServico os ON os.Veiculo_idVeiculo = v.idVeiculo JOIN vw_TotalOrdemServico t ON t.idOrdemServico = os.idOrdemServico WHERE os.Status = 'Concluida' GROUP BY c.idCliente, c.Nome HAVING SUM(t.TotalOrdem) > 600 ORDER BY ValorOrdensConcluidas DESC;

-- 09. Quais ordens abertas ou em execucao estavam atrasadas na data de referencia?
SELECT idOrdemServico, DataPrevista, DATEDIFF(@data_referencia, DataPrevista) AS DiasAtraso FROM OrdemServico WHERE Status IN ('Aberta','Em execucao') AND DataPrevista < @data_referencia ORDER BY DiasAtraso DESC, idOrdemServico;

-- 10. Quanto tempo levaram as ordens concluidas e houve atraso?
SELECT idOrdemServico, DATEDIFF(DataConclusao, DataEmissao) AS DiasAtendimento, CASE WHEN DataConclusao > DataPrevista THEN 'Com atraso' ELSE 'No prazo' END AS CumprimentoPrazo FROM OrdemServico WHERE Status = 'Concluida' ORDER BY idOrdemServico;

-- 11. Quais servicos aparecem mais nas ordens concluidas?
SELECT s.Descricao, SUM(oss.Quantidade) AS Unidades, COUNT(DISTINCT os.idOrdemServico) AS Ordens FROM Servico s JOIN ItemServico oss ON oss.Servico_idServico = s.idServico JOIN OrdemServico os ON os.idOrdemServico = oss.OrdemServico_idOrdemServico WHERE os.Status = 'Concluida' GROUP BY s.idServico, s.Descricao ORDER BY Unidades DESC, s.idServico;

-- 12. Qual o valor das pecas em ordens concluidas?
SELECT p.Codigo, p.Descricao, SUM(op.Quantidade) AS Quantidade, SUM(op.Quantidade * op.ValorUnitario) AS ValorPecas FROM Peca p JOIN ItemPeca op ON op.Peca_idPeca = p.idPeca JOIN OrdemServico os ON os.idOrdemServico = op.OrdemServico_idOrdemServico WHERE os.Status = 'Concluida' GROUP BY p.idPeca, p.Codigo, p.Descricao ORDER BY ValorPecas DESC;

-- 13. Quantas ordens em execucao cada equipe possui?
SELECT e.Nome, COUNT(os.idOrdemServico) AS OrdensEmExecucao FROM Equipe e LEFT JOIN OrdemServico os ON os.Equipe_idEquipe = e.idEquipe AND os.Status = 'Em execucao' GROUP BY e.idEquipe, e.Nome ORDER BY OrdensEmExecucao DESC, e.idEquipe;

-- 14. Quais mecanicos compoem cada equipe?
SELECT e.Nome AS Equipe, m.Nome AS Mecanico, m.Especialidade FROM Equipe e JOIN MecanicoEquipe em ON em.Equipe_idEquipe = e.idEquipe JOIN Mecanico m ON m.idMecanico = em.Mecanico_idMecanico ORDER BY e.idEquipe, m.idMecanico;

-- 15. Quais ordens aguardam autorizacao e qual seu valor orcado?
SELECT os.idOrdemServico, c.Nome, v.Placa, t.TotalOrdem AS ValorOrcado FROM OrdemServico os JOIN Veiculo v ON v.idVeiculo = os.Veiculo_idVeiculo JOIN Cliente c ON c.idCliente = v.Cliente_idCliente JOIN vw_TotalOrdemServico t ON t.idOrdemServico = os.idOrdemServico WHERE os.Autorizacao = 'Pendente' AND os.Status = 'Aberta' ORDER BY os.idOrdemServico;

-- 16. Quais servicos foram orcados por valor diferente da referencia atual?
SELECT oss.OrdemServico_idOrdemServico AS Ordem, s.Descricao, s.ValorReferencia, oss.ValorUnitario AS ValorPraticado, s.ValorReferencia - oss.ValorUnitario AS DiferencaPorUnidade FROM ItemServico oss JOIN Servico s ON s.idServico = oss.Servico_idServico WHERE oss.ValorUnitario <> s.ValorReferencia ORDER BY Ordem;

-- 17. Qual o valor e o ticket medio das ordens concluidas por equipe?
SELECT e.Nome, COUNT(*) AS OrdensConcluidas, SUM(t.TotalOrdem) AS ValorConcluido, ROUND(AVG(t.TotalOrdem),2) AS TicketMedio FROM Equipe e JOIN OrdemServico os ON os.Equipe_idEquipe = e.idEquipe JOIN vw_TotalOrdemServico t ON t.idOrdemServico = os.idOrdemServico WHERE os.Status = 'Concluida' GROUP BY e.idEquipe, e.Nome ORDER BY ValorConcluido DESC;

-- 18. Quais veiculos ainda nao possuem ordens?
SELECT v.Placa, v.Modelo, c.Nome FROM Veiculo v JOIN Cliente c ON c.idCliente = v.Cliente_idCliente WHERE NOT EXISTS (SELECT 1 FROM OrdemServico os WHERE os.Veiculo_idVeiculo = v.idVeiculo) ORDER BY v.idVeiculo;

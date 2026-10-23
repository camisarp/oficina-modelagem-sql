-- Dados inteiramente fictícios. Execute uma vez, após 01_criacao_oficina.sql.
USE oficina;
START TRANSACTION;
INSERT INTO Cliente (idCliente,Nome,CPF,Telefone,Email,Endereco) VALUES
(1,'Ana Lima','00000000001',NULL,'ana@example.com','Rua Exemplo, 10'),
(2,'Bruno Souza','00000000002',NULL,'bruno@example.com','Rua Exemplo, 20'),
(3,'Carla Alves','00000000003',NULL,'carla@example.com','Rua Exemplo, 30'),
(4,'Diego Santos','00000000004',NULL,'diego@example.com','Rua Exemplo, 40'),
(5,'Elisa Costa','00000000005',NULL,'elisa@example.com','Rua Exemplo, 50');
INSERT INTO Veiculo (idVeiculo,Cliente_idCliente,Placa,Marca,Modelo,Ano) VALUES
(1,1,'TST0A01','Fiat','Argo',2020),(2,1,'TST0A02','Honda','Fit',2018),
(3,2,'TST0A03','Toyota','Corolla',2021),(4,3,'TST0A04','Ford','Ka',2019),
(5,4,'TST0A05','Renault','Sandero',2017),(6,5,'TST0A06','Chevrolet','Onix',2022);
INSERT INTO Equipe (idEquipe,Nome) VALUES (1,'Revisao e manutencao'),(2,'Freios e suspensao'),(3,'Eletrica');
INSERT INTO Mecanico (idMecanico,Nome,Especialidade,Endereco) VALUES
(1,'Marcos Silva','Mecanica geral','Rua Oficina, 1'),(2,'Julia Rocha','Revisao','Rua Oficina, 2'),
(3,'Pedro Melo','Freios','Rua Oficina, 3'),(4,'Luana Reis','Eletrica','Rua Oficina, 4');
INSERT INTO MecanicoEquipe VALUES (1,1),(1,2),(2,1),(2,3),(3,4);
INSERT INTO Servico (idServico,Descricao,ValorReferencia) VALUES
(1,'Troca de oleo',100),(2,'Alinhamento',120),(3,'Revisao de freios',250),
(4,'Diagnostico eletrico',180),(5,'Revisao preventiva',300),(6,'Balanceamento por roda',30);
INSERT INTO Peca (idPeca,Codigo,Descricao,ValorReferencia) VALUES
(1,'OLEO-01','Oleo lubrificante - litro',45),(2,'FILTRO-01','Filtro de oleo',40),
(3,'FREIO-01','Jogo de pastilhas',220),(4,'BATERIA-01','Bateria',550),(5,'LAMP-01','Lampada',35);
INSERT INTO OrdemServico
(idOrdemServico,Veiculo_idVeiculo,Equipe_idEquipe,DataEmissao,DataPrevista,DataConclusao,Autorizacao,DataAutorizacao,Status,Quilometragem,RelatoCliente) VALUES
(1,1,1,'2026-10-01','2026-10-03','2026-10-02','Autorizada','2026-10-01','Concluida',45000,'Revisao e troca de oleo'),
(2,3,2,'2026-10-04','2026-10-06','2026-10-08','Autorizada','2026-10-04','Concluida',60000,'Ruido ao frear'),
(3,4,3,'2026-10-15','2026-10-18',NULL,'Autorizada','2026-10-15','Em execucao',70000,'Falha na partida'),
(4,2,1,'2026-10-20','2026-10-25',NULL,'Pendente',NULL,'Aberta',80000,'Orcamento de revisao'),
(5,3,3,'2026-10-10','2026-10-12',NULL,'Recusada',NULL,'Cancelada',60500,'Orcamento de iluminacao'),
(6,1,1,'2026-10-12','2026-10-14','2026-10-14','Autorizada','2026-10-12','Concluida',46000,'Alinhamento e balanceamento'),
(7,5,2,'2026-10-21','2026-10-24',NULL,'Autorizada','2026-10-21','Em execucao',95000,'Verificacao do sistema de freio'),
(8,4,3,'2026-10-22','2026-10-26',NULL,'Pendente',NULL,'Aberta',70100,'Aguardando avaliacao');
INSERT INTO ItemServico VALUES
(1,1,1,90),(1,5,1,300),(2,3,1,250),(2,2,1,120),
(3,4,1,180),(4,5,1,300),(5,4,1,180),
(6,2,1,120),(6,6,4,30),(7,3,1,250);
INSERT INTO ItemPeca VALUES
(1,1,4,45),(1,2,1,40),(2,3,1,220),(3,4,1,550),(3,5,2,35),(5,5,2,35),(7,3,1,220);
COMMIT;
SELECT 'Clientes' AS Tabela, COUNT(*) AS Quantidade FROM Cliente
UNION ALL SELECT 'Veiculos', COUNT(*) FROM Veiculo
UNION ALL SELECT 'Ordens', COUNT(*) FROM OrdemServico;

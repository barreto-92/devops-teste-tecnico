SELECT user_id, COUNT(*) AS total_chamados_abertos
FROM tickets
WHERE status = 'aberto'
GROUP BY user_id
ORDER BY total_chamados_abertos DESC;

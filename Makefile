build-hbase:
	docker build -t hbase:test -f ./containers/hbase/Dockerfile .

build-sparkbase:
	docker build -t sparkbase -f ./containers/spark/Dockerfile .
up:
	docker-compose up -d

down:
	docker-compose down -v

initHiveMetastore:
	docker exec hive schematool -dbType postgres -initSchema

startHiveServer2:
	docker exec hive hiveserver2

initmysqldata:
	cd datagenerator && python3 main.py


loadDimDate:
	docker cp data/dim_date.csv hadoop-namenode:/tmp
	docker exec hadoop-namenode hdfs dfs -mkdir /tmp
	docker exec hadoop-namenode hdfs dfs -put /tmp/dim_date.csv /tmp/dim_date.csv
	docker exec scheduler spark-submit --master yarn --deploy-mode client /opt/airflow/dags/Transformation//get_dim_date.py

ddl-silver:
	docker exec scheduler spark-submit --master yarn --deploy-mode client /opt/airflow/dags/ddl/create_silver_tables.py

start-spark-thrift-sever:
	docker exec contands start-thift-server.sh

setup: initHiveMetastore initmysqldata ddl-silver loadDimDate
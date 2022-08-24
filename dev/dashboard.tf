resource "aws_cloudwatch_dashboard" "EC2_Dashboard" {
  dashboard_name = "Ghost_Stack_Dashboard"
  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type":"metric",
            "x":0,
            "y":0,
            "width":24,
            "height":7,
            "properties":{
                "metrics":[
                    [
                        "AWS/EC2",
                        "CPUUtilization",
                        "AutoScalingGroupName",
                        "ghost_ec2_pool",
                        {
                            "stat": "Average"
                        }
                    ]
                ],
                "legend": {
                    "position": "hidden"
                },
                "period":60,
                "region":"us-east-1",
                "title":"ASG: Average CPU Utilization",
                "stacked":true,
                "timezone": "+0200",
                "view":"timeSeries",
                "annotations":{
                    "horizontal":[
                        {
                            "visible":true,
                            "color":"#9467bd",
                            "label":"Critical range",
                            "value":65,
                            "fill":"above",
                            "yAxis":"left"
                        }
                    ]
                }
            }
        },
        {
            "type":"metric",
            "x":0,
            "y":8,
            "width":12,
            "height":7,
            "properties":{
                "metrics":[
                    [
                        "ECS/ContainerInsights",
                        "CpuUtilized",
                        "ServiceName",
                        "ghost-fargate-service",
                        "ClusterName",
                        "ghost-fargate-service",
                        {
                            "stat": "Average"
                        }
                    ]
                ],
                "legend": {
                    "position": "hidden"
                },
                "period":60,
                "region":"us-east-1",
                "title":"ECS: Service CPU Utilization",
                "stacked":true,
                "timezone": "+0200",
                "view":"timeSeries",
                "annotations":{
                    "horizontal":[
                        {
                            "visible":true,
                            "color":"#9467bd",
                            "label":"Critical range",
                            "value":60,
                            "fill":"above",
                            "yAxis":"left"
                        }
                    ]
                }
            }
        },
        {
            "type":"metric",
            "x":13,
            "y":8,
            "width":12,
            "height":7,
            "properties":{
                "metrics":[
                    [
                        "ECS/ContainerInsights",
                        "RunningTaskCount",
                        "ServiceName",
                        "ghost-fargate-service",
                        "ClusterName",
                        "ghost-fargate-service"
                    ]
                ],
                "legend": {
                    "position": "hidden"
                },
                "period":60,
                "region":"us-east-1",
                "title":"ECS: Running Tasks Count",
                "stacked":false,
                "view":"timeSeries"
            }
        },
        {
            "type": "explorer",
            "width": 24,
            "height": 12,
            "x": 0,
            "y": 16,
            "properties": {
                "metrics": [
                    {
                        "metricName": "ClientConnections",
                        "resourceType": "AWS::EFS::FileSystem",
                        "stat": "SampleCount"
                    },
                    {
                        "metricName": "StorageBytes",
                        "resourceType": "AWS::EFS::FileSystem",
                        "stat": "Sum"
                    }
                ],
                "labels": [
                    {
                        "key": "Project",
                        "value": "CloudX"
                    }
                ],
                "widgetOptions": {
                    "legend": {
                        "position": "hidden"
                    },
                    "view": "timeSeries",
                    "rowsPerPage": 1,
                    "widgetsPerRow": 2
                },
                "period": 60,
                "title": "EFS Metrics"
            }
        },
        {
            "type": "explorer",
            "width": 24,
            "height": 16,
            "x": 0,
            "y": 29,
            "properties": {
                "metrics": [
                    {
                        "metricName": "CPUUtilization",
                        "resourceType": "AWS::RDS::DBInstance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "DatabaseConnections",
                        "resourceType": "AWS::RDS::DBInstance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "ReadIOPS",
                        "resourceType": "AWS::RDS::DBInstance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "WriteIOPS",
                        "resourceType": "AWS::RDS::DBInstance",
                        "stat": "Average"
                    }
                ],
                "labels": [
                    {
                        "key": "Project",
                        "value": "CloudX"
                    }
                ],
                "widgetOptions": {
                    "legend": {
                        "position": "hidden"
                    },
                    "view": "timeSeries",
                    "rowsPerPage": 2,
                    "widgetsPerRow": 2
                },
                "period": 60,
                "title": "RDS Metrics"
            }
        }
    ]
}
EOF
}

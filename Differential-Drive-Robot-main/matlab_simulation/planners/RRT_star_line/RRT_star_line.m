classdef RRT_star_line < handle
    %RRT_PRIMITIVES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nodes
        dt
        map_limit
        goal
        map
        k
        resolution
        maxIter
        numberIter
     
    end
    
    methods
        function obj = RRT_star_line(initial_state,sampling_time,limit,goal,map,resolution,maxIter)
            %RRT_PRIMITIVES Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.dt = sampling_time;
            obj.map_limit = limit;
            obj.goal = goal;
            obj.map = map;
            obj.k = [0.4770    0.5449];
            obj.resolution = resolution;
            obj.maxIter = maxIter;
            
            obj.numberIter = 1;
            size_state = size(initial_state);
            obj.nodes = zeros(maxIter,size_state(2));
            obj.nodes(1,:) = [initial_state(1) initial_state(2) initial_state(3) 0 0 0 0];
            
 
        end
        
        function add_nodes(obj,new_node)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %obj.nodes = vertcat(obj.nodes,new_node);
            %coder.varsize('obj.nodes');
            obj.numberIter = obj.numberIter + 1;
            obj.nodes(obj.numberIter,:) = new_node;
        end
        
        function finish = check_goal(obj,new_node)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            x = new_node(1);
            y = new_node(2);
            if((x - obj.goal(1))^2 < 0.01 & (y - obj.goal(2))^2 < 0.01)
                finish = 1;
            else
                finish = 0;
            end
        end
        
        function near_index = find_nearest(obj,new_node)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            number_of_nodes = obj.numberIter;
            %number_of_nodes = size(obj.nodes);
            %number_of_nodes = number_of_nodes(1);
            
            near_index = 1;
            best_distance = 10000;
            best_node = [0 0 0];
            
            for k = 1:number_of_nodes
                node = obj.nodes(k,:);
                x = node(1);
                y = node(2);
                theta = node(3); 
                distance = sqrt((x-new_node(1))^2 + (y-new_node(2))^2 + 1*0*(theta-new_node(3))^2);
                if(distance < best_distance)
                    best_distance = distance;
                    near_index = k;
                    best_node = node;
                end
            end
            
        end
        
        function near_index = find_nearest_minimum_cost(obj,new_node)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            number_of_nodes = obj.numberIter;
            %number_of_nodes = size(obj.nodes);
            %number_of_nodes = number_of_nodes(1);
            
            near_index = 1;
            best_cost = 10000;
            best_node = [0 0 0];
            
            for k = 1:number_of_nodes
                node = obj.nodes(k,:);
                x = node(1);
                y = node(2);
                theta = node(3); 
                cost = node(7);
                distance = sqrt((x-new_node(1))^2 + (y-new_node(2))^2);
                if(cost < best_cost & distance < 0.1)
                    best_cost = cost;
                    near_index = k;
                    best_node = node;
                end
            end
            
            if(best_cost == 10000)
                near_index = obj.find_nearest(new_node);
            end
        end

        
        function  find_nearest_ball(obj,new_node,distance_max)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            number_of_nodes = obj.numberIter;
            %number_of_nodes = size(obj.nodes);
            %number_of_nodes = number_of_nodes(1);
            
            near_nodes_index = [];
            
            for k = 2:number_of_nodes
                node = obj.nodes(k,:);
                x = node(1);
                y = node(2);
                theta = node(3); 
                distance = sqrt((x-new_node(1))^2 + (y-new_node(2))^2 + 1*0*(theta-new_node(3))^2);
                if(distance <= distance_max)
                    %best_distance = distance;
                    near_index = k;
                    %near_nodes_index = [k,near_nodes_index];
                    obj.rewire(new_node,near_index);
                end
            end
            
        end
        
        function near_index = choose_parent(obj,new_node)
            %BASED ON Number PATH TO THE NODE!!!
            
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            
            number_of_nodes = obj.numberIter;
            
            near_index = 1;
            best_cost = 10000;
            best_node = [0 0 0];
            
            for k = 1:number_of_nodes
                node = obj.nodes(k,:);
                x = node(1);
                y = node(2);
                theta = node(3); 
                cost = node(7);
                if(cost < best_cost)
                    best_cost = cost;
                    near_index = k;
                    best_node = node;
                end
            end
            
        end
        
     
        function rewire(obj,new_node,near_node_index)
            
            single_node = obj.nodes(near_node_index,:);
            parent = obj.nodes(single_node(4),:);
            distance_to_parent = sqrt((parent(1)-single_node(1))^2 + (parent(2)-single_node(2))^2);
            cost_to_parent = parent(7) + distance_to_parent;

            distance_to_new_node = sqrt((new_node(1)-single_node(1))^2 + (new_node(2)-single_node(2))^2);
            cost_to_new_node = new_node(7) + distance_to_new_node;
            if(cost_to_new_node < cost_to_parent)
                obj.nodes(near_node_index,4) = new_node(4);
            end
            
         end
        
        function desired_node = sample(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            sample_goal_prob = rand();
            if(sample_goal_prob > 0.8)
                desired_node = [obj.goal(1) obj.goal(2) 0];
            else
                rand_x = rand()*obj.map_limit(1);
                rand_y = rand()*obj.map_limit(2);
                rand_z = (rand() - 0.5)*pi;
                desired_node = [rand_x rand_y rand_z];
            end
        end
        
        
        function new_node = choose_primitives(obj,near_index, desired_node)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            near_node = obj.nodes(near_index,:);
            best_index = 1;
            best_distance = 10000;
            best_node = [0 0 0];
            %best_control = [obj.k obj.k];
            %best_control = [0 0];
            
            %to add dynamic
%             b = 0.05;
%              u1 = obj.k(1)*(desired_node(1) - near_node(1)) + obj.k(2)*(-near_node(5));
%              u2 = obj.k(2)*(desired_node(2) - near_node(2)) + obj.k(2)*(-near_node(6));
%              
%              u1 = u1 + near_node(5);
%              u2 = u2 + near_node(6);
%              best_control = [u1 u2];
%             
%             x_new = near_node(1) + u1*obj.dt;
%             y_new = near_node(2) + u2*obj.dt;
%             theta_new = near_node(3) + (u2*cos(near_node(3)) - u1*sin(near_node(3)))*obj.dt/b;% + w*obj.dt;
            
            

            u1 = desired_node(1) - near_node(1);
            if(abs(u1) > 0.05)
                if(u1 > 0)
                    u1 = 0.05;
                elseif(u1 < 0)
                    u1 = -0.05;
                end
            end
            u2 = desired_node(2) - near_node(2);
            if(abs(u2) > 0.05)
                if(u2 > 0)
                    u2 = 0.05;
                elseif(u2 < 0)
                    u2 = -0.05;
                end
            end
           best_control = [u1 u2];

            x_new = near_node(1) + u1;
            y_new = near_node(2) + u2;
            theta_new = 0;
            
            
            
            best_node = [x_new y_new theta_new];
            
            distance = sqrt((desired_node(1) - near_node(1))^2 + (desired_node(2) - near_node(2))^2);
            cost = near_node(7) + distance;
       
            
            new_node = [best_node near_index best_control cost];
        end
        
        
        function [path,size_path] = take_path(obj,index)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            final_node = obj.nodes(index,:);
            
            size_node = size(final_node);
            path = ones(obj.maxIter,size_node(2));
            path(1,:) = final_node;
            
            size_path = 0;
            %path = [final_node];
            for i = 1:(index)
                if(final_node(4) == 0)
                    break;
                end
                parent = obj.nodes(final_node(4),:);
                %path = vertcat(path,parent);
                path(i+1,:) = parent;
                final_node = parent;
                size_path = size_path+1;
            end
        end
        
        function good = check_collision(obj,node_to_check)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            x = node_to_check(1);
            y = node_to_check(2);
            theta = node_to_check(3);

            scale = 1/obj.resolution;
            
            if(x < 0 | y < 0)
                good = 0;
                return;
            end
            
            if(int16(x*scale)+1 > size(obj.map,1))
                good = 0;
                return;
            end
            if(int16(y*scale)+1 > size(obj.map,2))
                good = 0;
                return;
            end
            
            if(obj.map(int16(x*scale)+1,int16(y*scale)+1) < 250)
                good = 0;
            else
                good = 1;
            end
            
            
        end
        
    %end methods    
    end
%end class
end


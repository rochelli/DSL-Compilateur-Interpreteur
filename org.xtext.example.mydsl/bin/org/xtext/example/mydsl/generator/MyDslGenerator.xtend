/*
 * generated by Xtext 2.14.0
 */
package org.xtext.example.mydsl.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import fr.ut2j.m1ice.fsm.FSM
import org.eclipse.emf.common.util.EList
import fr.ut2j.m1ice.fsm.Transition
import fr.ut2j.m1ice.fsm.Final
import fr.ut2j.m1ice.fsm.Initial
import fr.ut2j.m1ice.fsm.State

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MyDslGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val myfsm = resource.contents.get(0) as FSM
		fsa.generateFile(myfsm.name+".java", publicClass(myfsm.name))
		fsa.generateFile("main.java", createMain(myfsm))
		fsa.generateFile("State.java", createAbstractClass("State"))
		fsa.generateFile("Final.java", instantiateState ("Final"))
		fsa.generateFile("Initial.java", instantiateState ("Initial"))
		myfsm.state.forEach[s | if(!(s instanceof Final) && !(s instanceof Initial)) fsa.generateFile(s.name + '.java', instantiateState (s.name))]
	}		
	
	def createMain(FSM myfsm) 
	'''package test;
	import java.util.Scanner; 
	import java.util.*;
public class main {
	 
	public static void main (String[] args){
		
		�FOR s:myfsm.state�
			�IF s instanceof Final�
				Final finale = new Final("�s.name�");
			�ELSEIF s instanceof Initial�
				Initial initial = new Initial("�s.name�");
			�ELSE�
				State �s.name� = new �s.name�("�s.name�");
			�ENDIF�
		�ENDFOR�
		�myfsm.name� dsl = new �myfsm.name�("�myfsm.name�", initial, finale);
		while (!(dsl.getCurrent() instanceof Final)){
			Scanner sc = new Scanner(System.in);
			System.out.println("Veuillez saisir un trigger :");
			String saisie = sc.nextLine();
			System.out.println("Vous avez saisi : " + saisie);
			System.out.println("Etat pr�c�dent "+dsl.getCurrent().getName());
			�FOR t:myfsm.transition�
				if (dsl.getCurrent().getName() == "�t.state.get(0).name�" && saisie.equals("�t.trigger�")) 
					�IF t.state.get(1) instanceof Final�
						dsl.setState(finale);
					�ELSE�
						dsl.setState(�t.state.get(1).name�);
					�ENDIF�
			�ENDFOR�
			System.out.println("Etat actuel "+dsl.getCurrent().getName());
		}
		System.out.println("La machine est dans son �tat final");
		
	}
}
	'''

	def instantiateState (String name) 
	'''package test;
public class �name� extends State{
		
	private String name;
	
	public �name� (String name){
		this.name = name;
	}
	
	public String getName (){
		return this.name;
	}
}
	'''
	
	def createAbstractClass (String name)
	'''package test;
public abstract class �name�{
	
	public abstract String getName ();

}
	'''
	
	def publicClass (String name) 
	'''package test;
public class �name� { 
		
	private String name;
	private State current;
	private Initial initial;
	private Final finale;
	
	public �name� (String name, Initial initialState, Final finalState){
		
		this.name = name;
		this.initial = initialState;
		this.finale = finalState;
		this.current = this.initial;
	}
	
	public void setState(State state){
		
		this.current = state;
	}
	
	public Initial getInitial(){
			
		return this.initial;
	}
		
	public Final getFinal(){
			
		return this.finale;
	}
	
	public State getCurrent(){
				
		return this.current;
	}
}
'''

}